using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Painting
{
    public class DecalPaint : MonoBehaviour, PaintInterface
    {
        [SerializeField]
        private Mesh m_Mesh;

        [SerializeField]
        private Material m_Material;

        private bool m_HasPaint = false;
        private Matrix4x4 m_Transform = Matrix4x4.identity;

        private readonly Dictionary<Camera, CommandBuffer> m_Cameras = new Dictionary<Camera, CommandBuffer>();

        #region Mono Behaviour

        private void OnEnable()
        {
            m_HasPaint = false;
            Core.instance.SetInterface(this);
        }

        private void OnDisable()
        {
            Core.instance.SetInterface(null);

            Dictionary<Camera, CommandBuffer>.Enumerator iter = m_Cameras.GetEnumerator();
            while (iter.MoveNext())
            {
                if (iter.Current.Key != null)
                {
                    iter.Current.Key.forceIntoRenderTexture = false;
                    iter.Current.Key.RemoveCommandBuffer(CameraEvent.BeforeForwardAlpha, iter.Current.Value);
                }
            }
            iter.Dispose();
            m_Cameras.Clear();
        }

        private void OnWillRenderObject()
        {
            if (!m_HasPaint)
                return;

            Camera camera = Camera.current;
            if (camera == null) return;
            CommandBuffer buffer = null;
            if (!m_Cameras.TryGetValue(camera, out buffer))
            {
                camera.forceIntoRenderTexture = true;

                buffer = new CommandBuffer();
                buffer.name = "Decal Painting";
                camera.AddCommandBuffer(CameraEvent.BeforeForwardAlpha, buffer);

                m_Cameras.Add(camera, buffer);
            }
            else
            {
                buffer.Clear();
            }

            buffer.DrawMesh(m_Mesh, m_Transform, m_Material);
        }

        #endregion

        #region PaintInterface

        public void Tick(float time)
        {
        }

        public void Create(Vector3 pos, Quaternion rotation, Vector3 forward)
        {
            if (m_Mesh != null && m_Material != null)
            {
                m_Transform.SetTRS(pos, rotation, Vector3.one);
                m_HasPaint = true;
            }
        }

        public void Clear()
        {
            m_HasPaint = false;
        }

        #endregion
    }
}
