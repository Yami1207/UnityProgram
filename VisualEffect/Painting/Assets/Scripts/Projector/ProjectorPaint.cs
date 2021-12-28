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
        /// 喷漆对象
        /// </summary>
        private GameObject m_PaintObject;

        #region Mono Behaviour

        private void Awake()
        {
            if (m_PaintPrefab != null)
            {
                m_PaintObject = GameObject.Instantiate(m_PaintPrefab, this.transform);
                m_PaintObject.SetActive(false);
            }
        }

        private void OnEnable()
        {
            Core.instance.SetInterface(this);
        }

        private void OnDisable()
        {
            Core.instance.SetInterface(null);
        }

        #endregion

        public void Create(Vector3 pos, Quaternion rotation, Vector3 forward)
        {
            if (m_PaintObject != null)
            {
                m_PaintObject.SetActive(true);
                m_PaintObject.transform.position = pos;
                m_PaintObject.transform.rotation = rotation;

                Projector projector = m_PaintObject.GetComponent<Projector>();
                if (projector != null && projector.material != null)
                    projector.material.SetVector(RAY_NORMAL_ID, forward);
            }
        }

        public void Tick(float time)
        {
        }

        public void Clear()
        {
            if (m_PaintObject != null)
                m_PaintObject.SetActive(false);
        }
    }
}
