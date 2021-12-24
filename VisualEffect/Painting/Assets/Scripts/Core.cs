using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    public class Core
    {
        private PaintInterface m_Interface;

        public void Tick(float time)
        {
            if (m_Interface == null)
                return;
            m_Interface.Tick(time);
        }

        /// <summary>
        /// 创建喷漆对象
        /// </summary>
        /// <param name="pos">喷漆对象坐标</param>
        /// <param name="rotation">喷漆对象朝向</param>
        /// <param name="forward">喷漆对象向上方向</param>
        /// <param name="callback">创建成功回调函数</param>
        public void CreatePaint(Vector3 pos, Quaternion rotation, Vector3 forward, System.Action<GameObject> callback)
        {
            if (m_Interface != null)
                m_Interface.Create(pos, rotation, forward, callback);
        }

        public void Clear()
        {
            if (m_Interface != null)
                m_Interface.Clear();
        }

        public void SetInterface(PaintInterface paint)
        {
            m_Interface = paint;
        }

        private static Core s_Instance;
        public static Core instance
        {
            get
            {
                if (s_Instance == null)
                    s_Instance = new Core();
                return s_Instance;
            }
        }
    }
}
