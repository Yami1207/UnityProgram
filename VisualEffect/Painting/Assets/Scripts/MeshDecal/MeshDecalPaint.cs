using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Painting
{
    public class MeshDecalPaint : MonoBehaviour, PaintInterface
    {
        [SerializeField]
        private bool m_UseOfflineData = false;
        public bool useOfflineData { set { m_UseOfflineData = value; } get { return m_UseOfflineData; } }

        // 喷漆对象层级
        [SerializeField]
        private LayerMask m_PaintLayer = 0;
        public LayerMask paintLayer { set { m_PaintLayer = value; } get { return m_PaintLayer; } }

        /// <summary>
        /// 喷漆图案大小
        /// </summary>
        //[SerializeField]
        private float m_PaintSize = 1.0f;
        public float paintSize { set { m_PaintSize = value; } get { return m_PaintSize; } }

        /// <summary>
        /// 检测背面偏移值
        /// </summary>
        [SerializeField]
        private float m_FaceCullingOffset = 0.01f;
        public float faceCullingOffset { set { m_FaceCullingOffset = value; } get { return m_FaceCullingOffset; } }

        /// <summary>
        /// 顶点坐标扩展值
        /// </summary>
        [SerializeField]
        private float m_PositionOffset = 0.01f;
        public float positionOffset { set { m_PositionOffset = value; } get { return m_PositionOffset; } }

        [SerializeField]
        private Material m_PaintMaterial;

        private bool m_IsInitialized = false;

        /// <summary>
        /// 喷漆对象
        /// </summary>
        private GameObject m_PaintObject;

        private PaintTask[] m_Tasks = new PaintTask[(int)TaskType.MaxTask];

        private TaskType m_CurrentTask = TaskType.None;

        private PaintCache m_Cache = new PaintCache();
        private PaintQueue m_Queue = new PaintQueue();

        private PaintParams m_Parameters;

        #region Mono Behaviour

        private void Awake()
        {
            m_PaintObject = new GameObject();
            m_PaintObject.transform.parent = this.transform;
            m_PaintObject.AddComponent<MeshFilter>();
            var renderer = m_PaintObject.AddComponent<MeshRenderer>();
            renderer.sharedMaterial = m_PaintMaterial;
            renderer.enabled = false;

            // 初始化Cache对象
            m_Cache.paintSize = new Vector3(m_PaintSize, m_PaintSize, m_PaintSize);
            m_Cache.paintLayer = m_PaintLayer;
            m_Cache.faceCullingOffset = m_FaceCullingOffset;
            m_Cache.positionOffset = m_PositionOffset;

            m_Tasks[(int)TaskType.PrePaint] = new PrePaint(m_Cache);
            m_Tasks[(int)TaskType.ProcessCacheST] = new ProcessCacheST(m_Cache);
            m_Tasks[(int)TaskType.ProcessCacheMT] = new ProcessCacheMT(m_Cache);
            m_Tasks[(int)TaskType.GenerateMesh] = new GenerateMesh(m_Cache);
            m_Tasks[(int)TaskType.PostPaint] = new PostPaint(m_Cache);

            if (m_UseOfflineData)
            {
                m_IsInitialized = false;
                this.StartCoroutine(this.LoadSceneMeshTreeAsync());
            }
            else
            {
                m_IsInitialized = true;
            }
        }

        private void OnEnable()
        {
            Core.instance.SetInterface(this);

            for (int i = 0; i < m_Tasks.Length; ++i)
                m_Tasks[i].OnEnable();
        }

        private void OnDisable()
        {
            for (int i = 0; i < m_Tasks.Length; ++i)
                m_Tasks[i].OnDisable();

            Core.instance.SetInterface(null);
        }

        private void OnDestroy()
        {
            for (int i = 0; i < m_Tasks.Length; ++i)
                m_Tasks[i].OnDestroy();
        }

        #endregion

        public void Tick(float time)
        {
            if (!m_IsInitialized)
                return;

            if (m_CurrentTask != TaskType.None)
            {
                if (m_Tasks[(int)m_CurrentTask].Run())
                {
                    m_CurrentTask = this.NextTask(m_CurrentTask);
                    if (m_CurrentTask != TaskType.None)
                        m_Tasks[(int)m_CurrentTask].Init();
                    else
                        m_Queue.OnPaintFinished(m_Parameters.id);
                }
            }
        }

        private TaskType NextTask(TaskType type)
        {
            switch (type)
            {
                case TaskType.PrePaint:
                    {
                        return m_UseOfflineData ? TaskType.ProcessCacheMT : TaskType.ProcessCacheST;
                    }
                case TaskType.ProcessCacheST:
                case TaskType.ProcessCacheMT:
                    {
                        return TaskType.GenerateMesh;
                    }
                case TaskType.GenerateMesh:
                    {
                        return TaskType.PostPaint;
                    }
            }

            return TaskType.None;
        }

        public void Create(Vector3 pos, Quaternion rotation, Vector3 forward, System.Action<GameObject> callback)
        {
            Debug.Assert(m_PaintObject != null);
            m_Queue.Enqueue(pos, rotation, forward, this.StartPaintFromQueue, callback);
        }

        public void Clear()
        {
        }

        private void StartPaintFromQueue(PaintParams p)
        {
            m_Parameters = p;

            m_PaintObject.transform.position = p.position;
            m_PaintObject.transform.rotation = p.rotation;
            m_Cache.paintObject = m_PaintObject;
            m_Cache.paintWorldToLocal = m_PaintObject.transform.worldToLocalMatrix;

            //if (m_PaintObject != null)
            //{
            //    m_PaintObject.transform.position = p.position;
            //    m_PaintObject.transform.rotation = p.rotation;
            //    m_Cache.paintObject = m_PaintObject;
            //    m_Cache.paintWorldToLocal = m_PaintObject.transform.worldToLocalMatrix;
            //}
            //else
            //{
            //    m_Cache.paintObject = null;
            //    m_Cache.paintWorldToLocal = Matrix4x4.identity;
            //}

            m_Cache.paintPoint = p.position;
#if UNITY_EDITOR
            m_Cache.paintSize = new Vector3(m_PaintSize, m_PaintSize, m_PaintSize);
            m_Cache.paintLayer = m_PaintLayer;
            m_Cache.faceCullingOffset = m_FaceCullingOffset;
            m_Cache.positionOffset = m_PositionOffset;
#endif

            // 
            m_CurrentTask = TaskType.PrePaint;
            m_Tasks[(int)m_CurrentTask].Init();
        }

        private IEnumerator LoadSceneMeshTreeAsync()
        {
            yield return 0;
            FileStream fileStream = File.Open(Application.streamingAssetsPath + "/Paint/" + SceneManager.GetActiveScene().name + ".data", FileMode.Open);
            if (fileStream == null)
            {
                m_IsInitialized = true;
                m_UseOfflineData = false;
            }
            else
            {
                BinaryReader reader = new BinaryReader(fileStream);
                m_Cache.tree = new SceneMeshTree();
                m_Cache.tree.Load(reader, true, () =>
                {
                    reader.Close();
                    fileStream.Close();
                    fileStream.Dispose();

                    m_IsInitialized = true;
                });
            }
        }
    }
}
