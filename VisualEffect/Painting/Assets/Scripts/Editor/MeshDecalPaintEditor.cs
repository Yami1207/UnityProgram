using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Painting
{
    [CustomEditor(typeof(MeshDecalPaint))]
    public class MeshDecalPaintEditor : UnityEditor.Editor
    {
        private float m_QuadtreeSize = 10.0f;

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            MeshDecalPaint paint = target as MeshDecalPaint;
            //paint.useOfflineData = EditorGUILayout.Toggle("使用离线数据", paint.useOfflineData);
            //paint.paintLayer = EditorGUILayout.LayerField("可喷漆的层级", paint.paintLayer);
            //paint.paintSize = EditorGUILayout.FloatField("喷漆图案大小", paint.paintSize);
            //paint.faceCullingOffset = EditorGUILayout.FloatField("检测背面偏移值", paint.faceCullingOffset);
            //paint.positionOffset = EditorGUILayout.FloatField("顶点坐标扩展值", paint.positionOffset);

            m_QuadtreeSize = EditorGUILayout.FloatField("四叉树区域最小值", m_QuadtreeSize);

            if (GUILayout.Button("生成离线数据"))
            {
                List<MeshRenderer> rendererList = new List<MeshRenderer>();

                // 遍历所有MeshRenderer
                MeshRenderer[] meshRendererArray = GameObject.FindObjectsOfType<MeshRenderer>();
                for (int i = 0; i < meshRendererArray.Length; ++i)
                {
                    MeshRenderer renderer = meshRendererArray[i];
                    if (renderer.enabled == false)
                        continue;

                    // 判断可否喷漆到对象上
                    if (((1 << renderer.gameObject.layer) & paint.paintLayer) != 0)
                        rendererList.Add(renderer);
                }

                SceneMeshTree tree = new SceneMeshTree();
                tree.Build(rendererList, m_QuadtreeSize);
            }
        }

        protected int AddMeshList(Mesh mesh, List<Mesh> list)
        {
            for (int i = 0; i < list.Count; ++i)
            {
                if (mesh.GetInstanceID() == list[i].GetInstanceID())
                    return i;
            }

            list.Add(mesh);
            return list.Count - 1;
        }
    }
}
