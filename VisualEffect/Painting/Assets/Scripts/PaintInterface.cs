using UnityEngine;

namespace Painting
{
    public interface PaintInterface
    {
        void Tick(float time);

        /// <summary>
        /// 创建喷漆对象
        /// </summary>
        /// <param name="pos"></param>
        /// <param name="rotation"></param>
        /// <param name="forward"></param>
        void Create(Vector3 pos, Quaternion rotation, Vector3 forward);

        void Clear();
    }
}
