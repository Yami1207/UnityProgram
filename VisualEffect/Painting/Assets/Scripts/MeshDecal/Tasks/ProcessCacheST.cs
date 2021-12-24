using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    class ProcessCacheST : PaintTask
    {
        private Bounds m_PaintBounds = new Bounds();

        public ProcessCacheST(PaintCache cache) : base(cache)
        {
        }

        public override void Init()
        {
            base.Init();

            m_PaintBounds.center = m_Cache.paintPoint;
            m_PaintBounds.size = m_Cache.paintSize;
        }

        public override bool Run()
        {
            // 获取场景所有MeshRenderer
            MeshRenderer[] meshRendererArray = GameObject.FindObjectsOfType<MeshRenderer>();

            // 遍历所有MeshRenderer
            for (int i = 0; i < meshRendererArray.Length; ++i)
            {
                MeshRenderer meshRenderer = meshRendererArray[i];
                if (meshRenderer.enabled == false)
                    continue;

                // 判断可否喷漆到对象上
                if (((1 << meshRenderer.gameObject.layer) & m_Cache.paintLayer) == 0)
                    continue;

                if (meshRenderer.bounds.Intersects(m_PaintBounds))
                    this.GenerateMesh(meshRenderer);
            }

            this.HandleZFighting();

            return true;
        }

        /// <summary>
        /// 生成Mesh
        /// </summary>
        /// <param name="renderer"></param>
        private void GenerateMesh(MeshRenderer renderer)
        {
            var vertexPool = m_Cache.vertexPool;
            var indexPool = m_Cache.indexPool;
            var polygonPool = m_Cache.polygonPool;

            // 清除缓存数据
            vertexPool.Clear();
            indexPool.Clear();

            var mesh = renderer.GetComponent<MeshFilter>().sharedMesh;
            mesh.GetVertices(vertexPool);
            mesh.GetIndices(indexPool, 0);

            // 将renderer转换到本地坐标
            var tranfosmMatrix = m_Cache.paintWorldToLocal * renderer.transform.localToWorldMatrix;

            // 遍历renderer的三角形
            for (int i = 0; i < indexPool.Count; i = i + 3)
            {
                int index1 = indexPool[i], index2 = indexPool[i + 1], index3 = indexPool[i + 2];

                // 获取本地坐标的顶点
                Vector3 v1 = tranfosmMatrix.MultiplyPoint(vertexPool[index1]);
                Vector3 v2 = tranfosmMatrix.MultiplyPoint(vertexPool[index2]);
                Vector3 v3 = tranfosmMatrix.MultiplyPoint(vertexPool[index3]);

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
    }
}
