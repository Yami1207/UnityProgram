using System.IO;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    public partial class SceneMeshTree
    {
        /// <summary>
        /// 对象缓存数据
        /// </summary>
        public class ObjectBuffer
        {
            /// <summary>
            /// 世界坐标系矩阵
            /// </summary>
            public Matrix4x4 transform = Matrix4x4.identity;

            /// <summary>
            /// 包围盒
            /// </summary>
            public Bounds bounds = new Bounds();

            /// <summary>
            /// 网格缓存索引
            /// </summary>
            public int meshIndex = -1;
        }

        /// <summary>
        /// 网格缓存数据
        /// </summary>
        public class MeshBuffer
        {
            /// <summary>
            /// 顶点坐标
            /// </summary>
            public Vector3[] vertices;

            /// <summary>
            /// 子网格数
            /// </summary>
            public int subMeshCount;

            /// <summary>
            /// 顶点索引
            /// </summary>
            public int[][] indices;
        }

        /// <summary>
        /// 四叉树节点
        /// </summary>
        private class TreeNode
        {
            /// <summary>
            /// 检测碰撞标识，防止同一个区域进行多次检测
            /// </summary>
            public int mark = 0;

            /// <summary>
            /// 父节点索引
            /// </summary>
            public int parent = -1;

            /// <summary>
            /// 区域范围
            /// </summary>
            public Bounds bounds;

            /// <summary>
            /// 对象索引
            /// </summary>
            public List<int> objects = new List<int>();
        }

        /// <summary>
        /// 保存检测后的对象索引
        /// </summary>
        private readonly List<int> m_ResultBuffer = new List<int>();
        public List<int> resultBuffer { get { return m_ResultBuffer; } }

        /// <summary>
        /// 当前检测碰撞标识
        /// </summary>
        private int m_TestCollisionMark = 0;

        /// <summary>
        /// 四叉树深度
        /// </summary>
        private int m_TreeDepth;

        /// <summary>
        /// 四叉树节点
        /// </summary>
        private TreeNode[] m_TreeNode;

        private readonly List<ObjectBuffer> m_ObjectBuffer = new List<ObjectBuffer>();
        private readonly List<MeshBuffer> m_MeshBuffer = new List<MeshBuffer>();

        private System.Action m_LoadedCallback;
        private BinaryReader m_BinaryReader;

        public void Load(BinaryReader reader, bool useThread, System.Action callback)
        {
            m_BinaryReader = reader;
            m_LoadedCallback = callback;

            if (useThread)
            {
                Thread thread = new Thread(ThreadRun);
                thread.IsBackground = true;
                thread.Start();
            }
            else
            {
                this.LoadSceneData();
            }
        }

        public void TestCollision(Bounds bounds)
        {
            m_ResultBuffer.Clear();
            ++m_TestCollisionMark;

            if (m_TreeNode == null)
                return;

            if (m_TreeDepth == 1)
            {
                for (int i = 0; i < m_ObjectBuffer.Count; ++i)
                {
                    var buffer = m_ObjectBuffer[i];
                    if (buffer.bounds.Intersects(bounds))
                        m_ResultBuffer.Add(i);
                }
            }
            else
            {
                TreeNode root = m_TreeNode[0];
                Vector3 minSize = m_TreeNode[m_TreeNode.Length - 1].bounds.size, offset = -root.bounds.center + 0.5f * root.bounds.size;
                Vector3 minBounds = bounds.min + offset, maxBounds = bounds.max + offset;
                int leaf = (int)Mathf.Pow(4, m_TreeDepth - 1), nodeIndex = m_TreeNode.Length - leaf;
                int mod = (int)Mathf.Sqrt(leaf);
                int sx = (int)(minBounds.x / minSize.x) % mod, ex = (int)(maxBounds.x / minSize.x) % mod;
                int sz = (int)(minBounds.z / minSize.z) % mod, ez = (int)(maxBounds.z / minSize.z) % mod;
                for (int i = sx; i <= ex; ++i)
                {
                    if (i < 0 || i >= mod) continue;
                    for (int j = sz; j <= ez; ++j)
                    {
                        if (j < 0 || j >= mod) continue;
                        this.TestCollision(nodeIndex + j * mod + i, bounds, m_TestCollisionMark);
                    }
                }
            }
        }

        /// <summary>
        /// 检测节点与包围盒碰撞
        /// </summary>
        /// <param name="nodeIndex"></param>
        /// <param name="bounds"></param>
        /// <param name="mark"></param>
        private void TestCollision(int nodeIndex, Bounds bounds, int mark)
        {
            var node = m_TreeNode[nodeIndex];
            if (node.mark == mark)
                return;

            for (int i = 0; i < node.objects.Count; ++i)
            {
                int index = node.objects[i];
                var buffer = m_ObjectBuffer[index];
                if (buffer.bounds.Intersects(bounds))
                    m_ResultBuffer.Add(index);
            }

            node.mark = mark;
            if (node.parent != -1)
                this.TestCollision(node.parent, bounds, mark);
        }

        public ObjectBuffer GetObjectBuffer(int index)
        {
            return m_ObjectBuffer[index];
        }

        public MeshBuffer GetMeshBuffer(int index)
        {
            return m_MeshBuffer[index];
        }

        private void LoadSceneData()
        {
            try
            {
                if (m_BinaryReader == null)
                    return;

                // 加载对象数据
                this.LoadObjects(m_BinaryReader);

                // 加载mesh数据
                this.LoadMeshes(m_BinaryReader);

                // 加载四叉树数据
                this.LoadTreeNodes(m_BinaryReader);
            }
            catch
            {
            }
            finally
            {
                if (m_LoadedCallback != null)
                {
                    var callback = m_LoadedCallback;
                    m_LoadedCallback = null;
                    callback.Invoke();
                }
            }
        }

        private void LoadObjects(BinaryReader reader)
        {
            Vector3 center = Vector3.zero, size = Vector3.one;

            // 清空缓存数据
            m_ObjectBuffer.Clear();

            // 读取object数
            int numObjects = reader.ReadInt32();

            // 读取obj信息
            for (int i = 0; i < numObjects; ++i)
            {
                var obj = new ObjectBuffer();

                // 矩阵数据
                for (int j = 0; j < 16; ++j)
                    obj.transform[j] = reader.ReadSingle();

                // 包围盒数据
                this.ReadVector3(reader, ref center);
                this.ReadVector3(reader, ref size);
                obj.bounds.center = center;
                obj.bounds.size = size;

                // mesh索引
                obj.meshIndex = reader.ReadInt32();

                // 添加到列表中
                m_ObjectBuffer.Add(obj);
            }
        }

        private void LoadMeshes(BinaryReader reader)
        {
            m_MeshBuffer.Clear();

            // 读取object数
            int numMeshes = m_BinaryReader.ReadInt32();

            // 读取mesh数据
            for (int i = 0; i < numMeshes; ++i)
            {
                var buffer = new MeshBuffer();

                // 顶点数据
                int numVertices = m_BinaryReader.ReadInt32();
                buffer.vertices = new Vector3[numVertices];
                for (int j = 0; j < numVertices; ++j)
                    this.ReadVector3(m_BinaryReader, ref buffer.vertices[j]);

                // submesh数
                buffer.subMeshCount = m_BinaryReader.ReadInt32();
                buffer.indices = new int[buffer.subMeshCount][];

                // 顶点索引
                for (int j = 0; j < buffer.subMeshCount; ++j)
                {
                    int numIndices = m_BinaryReader.ReadInt32();
                    buffer.indices[j] = new int[numIndices];

                    var indices = buffer.indices[j];
                    for (int k = 0; k < numIndices; ++k)
                        indices[k] = m_BinaryReader.ReadInt32();
                }

                m_MeshBuffer.Add(buffer);
            }
        }

        /// <summary>
        /// 加载四叉树
        /// </summary>
        /// <param name="reader"></param>
        private void LoadTreeNodes(BinaryReader reader)
        {
            // 创建
            m_TreeDepth = reader.ReadInt32();
            int numNodes = reader.ReadInt32();
            m_TreeNode = new TreeNode[numNodes];

            Vector3 minBounds = Vector3.zero, maxBounds = Vector3.zero;
            this.ReadVector3(m_BinaryReader, ref minBounds);
            this.ReadVector3(m_BinaryReader, ref maxBounds);
            Vector3 size = maxBounds - minBounds, center = minBounds + 0.5f * size;
            this.InitTreeNode(0, 0, -1, center, size, 1, m_TreeDepth);

            int temp = reader.ReadInt32();
            for (int i = 0; i < temp; ++i)
            {
                int index = reader.ReadInt32(), count = reader.ReadInt32();
                var node = m_TreeNode[index];
                for (int j = 0; j < count; ++j)
                    node.objects.Add(reader.ReadInt32());
            }
        }

        /// <summary>
        /// 初始化四叉树节点
        /// </summary>
        /// <param name="depthFirstIndex">深度depth所在数组的首位置</param>
        /// <param name="depthIndex">节点在深度depth的相对位置</param>
        /// <param name="parent"></param>
        /// <param name="center"></param>
        /// <param name="size"></param>
        /// <param name="depth"></param>
        /// <param name="maxDepth"></param>
        private void InitTreeNode(int depthFirstIndex, int depthIndex, int parent, Vector3 center, Vector3 size, int depth, int maxDepth)
        {
            int index = depthFirstIndex + depthIndex;

            // 初始化节点
            m_TreeNode[index] = new TreeNode();
            var node = m_TreeNode[index];
            node.parent = parent;
            node.bounds.center = center;
            node.bounds.size = size;

            if (depth < maxDepth)
            {
                // 当前层总节点数
                int maxNode = (int)Mathf.Pow(4, depth - 1);

                // 当前层行列数
                int mod = (int)Mathf.Sqrt(maxNode);

                // 下一层行列数
                int nextDepthMod = (int)Mathf.Sqrt((int)Mathf.Pow(4, depth));

                // 下一层首节点索引
                int nextDepthFirstIndex = depthFirstIndex + maxNode;

                // 首个子节点索引
                int childIndex = 2 * ((depthIndex % mod) + (int)(depthIndex / mod) * nextDepthMod);

                Vector3 newSize = new Vector3(0.5f * size.x, size.y, 0.5f * size.z), offset = 0.5f * newSize;
                Vector3 pos = center + new Vector3(-offset.x, 0.0f, -offset.z);
                this.InitTreeNode(nextDepthFirstIndex, childIndex, index, pos, newSize, depth + 1, maxDepth);

                pos = center + new Vector3(offset.x, 0.0f, -offset.z);
                this.InitTreeNode(nextDepthFirstIndex, childIndex + 1, index, pos, newSize, depth + 1, maxDepth);

                childIndex = 2 * (depthIndex % mod) + (int)((depthIndex / mod) * 2 + 1) * nextDepthMod;

                pos = center + new Vector3(-offset.x, 0.0f, offset.z);
                this.InitTreeNode(nextDepthFirstIndex, childIndex, index, pos, newSize, depth + 1, maxDepth);

                pos = center + new Vector3(offset.x, 0.0f, offset.z);
                this.InitTreeNode(nextDepthFirstIndex, childIndex + 1, index, pos, newSize, depth + 1, maxDepth);
            }
        }

        private void ReadVector3(BinaryReader reader, ref Vector3 v)
        {
            v.x = reader.ReadSingle();
            v.y = reader.ReadSingle();
            v.z = reader.ReadSingle();
        }

        private void ThreadRun()
        {
            try
            {
                this.LoadSceneData();
            }
            finally
            {
            }
        }
    }
}
