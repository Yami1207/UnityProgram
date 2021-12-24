using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Painting
{
    public class ProjectorPaint : MonoBehaviour, PaintInterface
    {
        private readonly int MAIN_TEX_ID = Shader.PropertyToID("_MainTex");
        private readonly int RAY_NORMAL_ID = Shader.PropertyToID("_RayNormal");

        /// <summary>
        /// 喷漆对象预制体
        /// </summary>
        [SerializeField]
        private GameObject m_PaintPrefab;

        /// <summary>
        /// 喷漆最大数
        /// </summary>
        [SerializeField]
        private int m_MaxPaints = 1;

        /// <summary>
        /// 下次激活喷漆索引
        /// </summary>
        private int m_NextPaint = 0;

        /// <summary>
        /// 喷漆对象缓冲池
        /// </summary>
        private GameObject[] m_PaintPool;

        private void Awake()
        {
            Core.instance.SetInterface(this);

            if (m_MaxPaints > 0)
            {
                m_PaintPool = new GameObject[m_MaxPaints];
                for (int i = 0; i < m_PaintPool.Length; ++i)
                {
                    GameObject obj = GameObject.Instantiate(m_PaintPrefab, this.transform);
                    obj.SetActive(false);
                    m_PaintPool[i] = obj;
                }
            }
        }

        private void OnDisable()
        {
            Core.instance.SetInterface(null);
        }

        public void Create(Vector3 pos, Quaternion rotation, Vector3 forward, System.Action<GameObject> callback)
        {
            if (m_MaxPaints <= 0 || m_PaintPool == null)
                return;

            if (m_PaintPool[m_NextPaint] == null)
                return;

            var paint = m_PaintPool[m_NextPaint];
            paint.SetActive(true);
            paint.transform.position = pos;
            paint.transform.rotation = rotation;

            Projector projector = paint.GetComponent<Projector>();
            if (projector != null && projector.material != null)
                projector.material.SetVector(RAY_NORMAL_ID, forward);

            m_NextPaint = (++m_NextPaint) % m_MaxPaints;

            if (callback != null)
                callback.Invoke(paint);
        }

        public void Tick(float time)
        {
        }

        public void Clear()
        {
            // 隐藏喷漆对象
            for (int i = 0; i < m_PaintPool.Length; ++i)
                m_PaintPool[i].SetActive(false);
        }
    }
}
