using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    class GenerateMesh : PaintTask
    {
        public GenerateMesh(PaintCache cache) : base(cache)
        {
        }

        public override bool Run()
        {
            UnityEngine.Profiling.Profiler.BeginSample("Paint.GenerateMesh.Run");

            if (m_Cache.paintObject != null)
            {
                var filter = m_Cache.paintObject.GetComponent<MeshFilter>();
                if (filter != null)
                {
                    Mesh destroyMesh = filter.sharedMesh;
                    filter.sharedMesh = null;
                    GameObject.DestroyImmediate(destroyMesh);

                    // 创建Mesh数据
                    Mesh newMesh = new Mesh();
                    newMesh.Clear(true);
                    newMesh.SetVertices(m_Cache.vertices);
                    newMesh.SetNormals(m_Cache.normals);
                    newMesh.SetUVs(0, m_Cache.texcoords);
                    newMesh.SetTriangles(m_Cache.indices, 0);
                    newMesh.RecalculateBounds();
                    newMesh.UploadMeshData(true);

                    // 清空Mesh临时数据
                    m_Cache.vertices.Clear();
                    m_Cache.normals.Clear();
                    m_Cache.texcoords.Clear();
                    m_Cache.indices.Clear();

                    // 设置
                    filter.sharedMesh = newMesh;
                }
            }

            UnityEngine.Profiling.Profiler.EndSample();

            return true;
        }
    }
}
