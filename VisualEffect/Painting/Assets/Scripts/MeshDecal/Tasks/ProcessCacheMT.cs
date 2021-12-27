using System.Threading;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    class ProcessCacheMT : PaintTask
    {
        private volatile bool m_Running = false;

        private Bounds m_PaintBounds = new Bounds();

        private Thread m_Thread;
        private readonly ManualResetEvent m_ManualResetEvent = new ManualResetEvent(false);

        public ProcessCacheMT(PaintCache cache) : base(cache)
        {
            m_Thread = new Thread(ThreadRun);
            m_Thread.IsBackground = true;
            m_Thread.Start();
        }

        public override void Init()
        {
            base.Init();

            m_PaintBounds.center = m_Cache.paintPoint;
            m_PaintBounds.size = m_Cache.paintSize;

            m_Running = true;
            m_ManualResetEvent.Set();
        }

        public override bool Run()
        {
            return !m_Running;
        }

        public override void OnDestroy()
        {
            m_Thread.Abort();
            m_ManualResetEvent.Close();
        }

        /// <summary>
        /// 生成mesh数据
        /// </summary>
        /// <param name="transform"></param>
        /// <param name="buffer"></param>
        private void GenerateMesh(Matrix4x4 transform, SceneMeshTree.MeshBuffer buffer)
        {
            List<Vector3> polygonPool = ListPool<Vector3>.Get();

            // 转换到喷漆对象本地坐标
            var tranfosmMatrix = m_Cache.paintWorldToLocal * transform;
            var vertices = buffer.vertices;

            for (int i = 0; i < buffer.subMeshCount; ++i)
            {
                var indices = buffer.indices[i];
                for (int j = 0; j < indices.Length; j = j + 3)
                {
                    int index1 = indices[j], index2 = indices[j + 1], index3 = indices[j + 2];

                    // 获取本地坐标的顶点
                    Vector3 v1 = tranfosmMatrix.MultiplyPoint(vertices[index1]);
                    Vector3 v2 = tranfosmMatrix.MultiplyPoint(vertices[index2]);
                    Vector3 v3 = tranfosmMatrix.MultiplyPoint(vertices[index3]);

                    // 剔除背面三角形
                    var n = Vector3.Normalize(Vector3.Cross(v1 - v2, v1 - v3));
                    if (Vector3.Dot(n, -Vector3.forward) < m_Cache.faceCullingOffset)
                        continue;

                    // 裁剪三角形
                    Utility.TestIntersect(v1, v2, v3, polygonPool);
                    if (polygonPool.Count >= 3)
                        this.AddPolygon(polygonPool, n);
                    polygonPool.Clear();
                }
            }

            ListPool<Vector3>.Release(polygonPool);
        }

        /// <summary>
        /// 添加多边形
        /// </summary>
        /// <param name="polygon"></param>
        /// <param name="normal"></param>
        private void AddPolygon(List<Vector3> polygon, Vector3 normal)
        {
            var indices = m_Cache.indices;

            int index0 = this.AddVectex(polygon[0], normal), index1, index2;
            for (int i = 1; i < polygon.Count - 1; ++i)
            {
                index1 = this.AddVectex(polygon[i], normal);
                index2 = this.AddVectex(polygon[i + 1], normal);

                indices.Add(index0);
                indices.Add(index1);
                indices.Add(index2);
            }
        }

        /// <summary>
        /// 添加顶点
        /// </summary>
        /// <param name="vertex"></param>
        /// <param name="normal"></param>
        /// <returns></returns>
        private int AddVectex(Vector3 vertex, Vector3 normal)
        {
            int index = Utility.FindVertex(vertex, m_Cache.vertices);
            if (index == -1)
            {
                m_Cache.vertices.Add(vertex);
                m_Cache.normals.Add(normal);

                // 计算UV
                Vector3 proj = vertex - Vector3.Dot(vertex, Vector3.forward) * Vector3.forward;
                float u = proj.x + 0.5f;
                float v = proj.y + 0.5f;
                m_Cache.texcoords.Add(new Vector2(u, v));

                return m_Cache.vertices.Count - 1;
            }

            // 由于顶点是共享,需要重新计算法线
            m_Cache.normals[index] = (m_Cache.normals[index] + normal);
            m_Cache.normals[index].Normalize();
            return index;
        }

        /// <summary>
        /// 扩展顶点（解决渲染时出现闪烁）
        /// </summary>
        private void HandleZFighting()
        {
            var vertices = m_Cache.vertices;
            var normals = m_Cache.normals;
            var offset = m_Cache.positionOffset;

            for (int i = 0; i < vertices.Count; ++i)
                vertices[i] += offset * normals[i];
        }

        /// <summary>
        /// 使用线程生成mesh数据
        /// </summary>
        private void ThreadRun()
        {
            m_ManualResetEvent.WaitOne();

            try
            {
                SceneMeshTree tree = m_Cache.tree;
                if (tree != null)
                {
                    tree.TestCollision(m_PaintBounds);
                    var result = tree.resultBuffer;
                    for (int i = 0; i < result.Count; ++i)
                    {
                        var buffer = tree.GetObjectBuffer(result[i]);
                        if (buffer.meshIndex == -1) continue;
                        this.GenerateMesh(buffer.transform, tree.GetMeshBuffer(buffer.meshIndex));
                    }

                    this.HandleZFighting();
                }
            }
            finally
            {
                m_Running = false;

                m_ManualResetEvent.Reset();
                m_Thread = new Thread(ThreadRun);
                m_Thread.IsBackground = true;
                m_Thread.Start();
            }
        }
    }
}
