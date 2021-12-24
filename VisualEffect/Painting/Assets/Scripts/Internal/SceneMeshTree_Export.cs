using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using UnityEngine.SceneManagement;

namespace Painting
{
    public partial class SceneMeshTree
    {
#if UNITY_EDITOR
        private Dictionary<int, int> m_MeshBufferCache = new Dictionary<int, int>();

        private List<Vector3> m_TempVexterList = new List<Vector3>();
        private List<int> m_TempIndexList = new List<int>();

        public bool Build(List<MeshRenderer> rendererList, float minSize)
        {
            if (rendererList.Count == 0)
                return false;

            // 场景区域最小值和最大值
            Vector3 minBounds = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
            Vector3 maxBounds = new Vector3(float.MinValue, float.MinValue, float.MinValue);

            for (int i = 0; i < rendererList.Count; ++i)
            {
                var renderer = rendererList[i];

                // 场景范围最小值
                Bounds rb = renderer.bounds;
                Vector3 temp = rb.min;
                if (minBounds.x > temp.x) minBounds.x = temp.x;
                if (minBounds.y > temp.x) minBounds.y = temp.y;
                if (minBounds.z > temp.x) minBounds.z = temp.z;

                // 场景范围最大值
                temp = rb.max;
                if (maxBounds.x < temp.x) maxBounds.x = temp.x;
                if (maxBounds.y < temp.x) maxBounds.y = temp.y;
                if (maxBounds.z < temp.x) maxBounds.z = temp.z;

                ObjectBuffer objectBuffer = new ObjectBuffer();
                objectBuffer.transform = renderer.gameObject.transform.localToWorldMatrix;
                objectBuffer.bounds.center = renderer.bounds.center;
                objectBuffer.bounds.size = renderer.bounds.size;
                objectBuffer.meshIndex = this.AddMesh(renderer.GetComponent<MeshFilter>().sharedMesh);
                m_ObjectBuffer.Add(objectBuffer);
            }

            int depth = this.CalcDepth((int)Mathf.Abs(maxBounds.x - minBounds.x), (int)Mathf.Abs(maxBounds.z - minBounds.z), minSize);
            if (depth == -1) return false;
            this.CreateNodes(minBounds, maxBounds, depth);

            for (int i = 0; i < m_ObjectBuffer.Count; ++i)
                this.InsertObjectToTree(i, 0, 0, 1, depth);

            // 导出数据
            try
            {
                string path = Application.streamingAssetsPath + "/Paint";
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);

                FileStream fileStream = File.Open(path + "/" + SceneManager.GetActiveScene().name + ".data", FileMode.OpenOrCreate);
                BinaryWriter binaryWriter = new BinaryWriter(fileStream);

                this.ExportObjectBuffer(binaryWriter);
                this.ExportMeshBuffer(binaryWriter);
                this.ExportTreeNodes(binaryWriter, minBounds, maxBounds, depth);

                binaryWriter.Close();
                fileStream.Close();
                fileStream.Dispose();

                UnityEditor.AssetDatabase.Refresh();
            }
            catch
            {
            }

            return true;
        }

        private void CreateNodes(Vector3 minBounds, Vector3 maxBounds, int depth)
        {
            int numNodes = 1;
            for (int i = 1; i < depth; ++i)
                numNodes += (int)Mathf.Pow(4, i);

            m_TreeNode = new TreeNode[numNodes];
            Vector3 size = maxBounds - minBounds, center = minBounds + 0.5f * size;
            this.InitTreeNode(0, 0, -1, center, size, 1, depth);
        }

        private void InsertObjectToTree(int objectIndex, int depthFirstIndex, int depthIndex, int depth, int maxDepth)
        {
            int nodeIndex = depthFirstIndex + depthIndex;
            var node = m_TreeNode[nodeIndex];
            var obj = m_ObjectBuffer[objectIndex];
            int numCollision = 0;

            if (depth != maxDepth)
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
                int insertChild = childIndex;

                TreeNode childNode = m_TreeNode[nextDepthFirstIndex + childIndex];
                if (childNode.bounds.Intersects(obj.bounds))
                    ++numCollision;

                childNode = m_TreeNode[nextDepthFirstIndex + childIndex + 1];
                if (childNode.bounds.Intersects(obj.bounds))
                {
                    insertChild = childIndex + 1;
                    ++numCollision;
                }

                childIndex = 2 * (depthIndex % mod) + ((int)(depthIndex / mod) * 2 + 1) * nextDepthMod;
                childNode = m_TreeNode[nextDepthFirstIndex + childIndex];
                if (childNode.bounds.Intersects(obj.bounds))
                {
                    insertChild = childIndex;
                    ++numCollision;
                }

                childNode = m_TreeNode[nextDepthFirstIndex + childIndex + 1];
                if (childNode.bounds.Intersects(obj.bounds))
                {
                    insertChild = childIndex + 1;
                    ++numCollision;
                }

                if (numCollision == 1)
                    this.InsertObjectToTree(objectIndex, nextDepthFirstIndex, insertChild, depth + 1, maxDepth);
                else
                    node.objects.Add(objectIndex);
            }
            else
            {
                node.objects.Add(objectIndex);
            }
        }

        private int AddMesh(Mesh mesh)
        {
            int index = -1;
            if (m_MeshBufferCache.TryGetValue(mesh.GetInstanceID(), out index))
                return index;

            MeshBuffer newBuffer = new MeshBuffer();

            // 复制顶点坐标
            m_TempVexterList.Clear();
            mesh.GetVertices(m_TempVexterList);
            newBuffer.vertices = new Vector3[m_TempVexterList.Count];
            Array.Copy(m_TempVexterList.ToArray(), newBuffer.vertices, m_TempVexterList.Count);

            // 
            newBuffer.subMeshCount = mesh.subMeshCount;

            // 复制顶点索引
            newBuffer.indices = new int[newBuffer.subMeshCount][];
            for (int i = 0; i < newBuffer.subMeshCount; ++i)
            {
                m_TempIndexList.Clear();
                mesh.GetIndices(m_TempIndexList, i);
                newBuffer.indices[i] = new int[m_TempIndexList.Count];
                Array.Copy(m_TempIndexList.ToArray(), newBuffer.indices[i], m_TempIndexList.Count);
            }

            m_MeshBuffer.Add(newBuffer);
            m_MeshBufferCache.Add(mesh.GetInstanceID(), m_MeshBuffer.Count - 1);
            return m_MeshBuffer.Count - 1;
        }

        /// <summary>
        /// 计算四叉树深度
        /// </summary>
        /// <param name="width"></param>
        /// <param name="height"></param>
        /// <param name="minSize"></param>
        /// <returns></returns>
        private int CalcDepth(int width, int height, float minSize)
        {
            if (minSize < Mathf.Epsilon)
                return -1;

            float mapSize = Mathf.Max(width, height);
            if (mapSize < Mathf.Epsilon)
                return -1;

            int depth = 1;
            while (true)
            {
                if (Mathf.Round(mapSize / Mathf.Pow(2, depth)) <= minSize)
                    return depth;
                ++depth;
            }
        }

        private void ExportObjectBuffer(BinaryWriter binaryWriter)
        {
            // 写入object数
            binaryWriter.Write(m_ObjectBuffer.Count);

            // 写入每个obj信息
            for (int i = 0; i < m_ObjectBuffer.Count; ++i)
            {
                var obj = m_ObjectBuffer[i];

                // 矩阵数据
                for (int j = 0; j < 16; ++j)
                    binaryWriter.Write(obj.transform[j]);

                // 包围盒数据
                this.WriteVector3(binaryWriter, obj.bounds.center);
                this.WriteVector3(binaryWriter, obj.bounds.size);

                // mesh索引
                binaryWriter.Write(obj.meshIndex);
            }
        }

        private void ExportMeshBuffer(BinaryWriter binaryWriter)
        {
            // 写入mesh数
            binaryWriter.Write(m_MeshBuffer.Count);

            // 写入每个mesh数据
            for (int i = 0; i < m_MeshBuffer.Count; ++i)
            {
                var mesh = m_MeshBuffer[i];

                // 顶点数
                binaryWriter.Write(mesh.vertices.Length);

                // 顶点数据
                for (int j = 0; j < mesh.vertices.Length; ++j)
                    this.WriteVector3(binaryWriter, mesh.vertices[j]);

                // submesh数
                binaryWriter.Write(mesh.subMeshCount);

                for (int j = 0; j < mesh.subMeshCount; ++j)
                {
                    var indices = mesh.indices[j];

                    // 顶点索引数
                    binaryWriter.Write(indices.Length);

                    for (int k = 0; k < indices.Length; ++k)
                        binaryWriter.Write(indices[k]);
                }
            }
        }

        /// <summary>
        /// 导出四叉树数据
        /// </summary>
        /// <param name="binaryWriter"></param>
        /// <param name="minBounds"></param>
        /// <param name="maxBounds"></param>
        /// <param name="depth"></param>
        private void ExportTreeNodes(BinaryWriter binaryWriter, Vector3 minBounds, Vector3 maxBounds, int depth)
        {
            // 
            binaryWriter.Write(depth);
            binaryWriter.Write(m_TreeNode.Length);

            this.WriteVector3(binaryWriter, minBounds);
            this.WriteVector3(binaryWriter, maxBounds);

            List<int> writeNode = new List<int>();
            for (int i = 0; i < m_TreeNode.Length; ++i)
            {
                var node = m_TreeNode[i];
                if (node.objects.Count != 0)
                    writeNode.Add(i);
            }

            binaryWriter.Write(writeNode.Count);
            for (int i = 0; i < writeNode.Count; ++i)
            {
                int index = writeNode[i];
                var node = m_TreeNode[index];
                binaryWriter.Write(index);
                binaryWriter.Write(node.objects.Count);
                for (int j = 0; j < node.objects.Count; ++j)
                    binaryWriter.Write(node.objects[j]);
            }
        }

        private void WriteVector3(BinaryWriter writer, Vector3 value)
        {
            writer.Write(value.x);
            writer.Write(value.y);
            writer.Write(value.z);
        }
#endif
    }
}
