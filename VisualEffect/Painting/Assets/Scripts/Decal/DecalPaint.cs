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

        private readonly Dictionary<Camera, CommandBuffer> m_Cameras = new Dictionary<Camera, CommandBuffer>();

        #region Mono Behaviour

        private void OnEnable()
        {
            Core.instance.SetInterface(this);
        }

        private void OnDisable()
        {
            Core.instance.SetInterface(null);

            Dictionary<Camera, CommandBuffer>.Enumerator iter = m_Cameras.GetEnumerator();
            while (iter.MoveNext())
            {
                if (iter.Current.Key != null)
                    iter.Current.Key.RemoveCommandBuffer(CameraEvent.BeforeForwardAlpha, iter.Current.Value);
            }
            iter.Dispose();
            m_Cameras.Clear();
        }

        private void OnWillRenderObject()
        {
            
        }

        #endregion

        #region PaintInterface

        public void Tick(float time)
        {
        }

        public void Create(Vector3 pos, Quaternion rotation, Vector3 forward, System.Action<GameObject> callback)
        {

        }

        public void Clear()
        {
        }

        #endregion
    }
}
