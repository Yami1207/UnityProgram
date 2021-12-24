using System.Collections;
using System.Collections.Generic;

namespace Painting
{
    public enum TaskType
    {
        None = -1,
        PrePaint,
        ProcessCacheST,
        ProcessCacheMT,
        GenerateMesh,
        PostPaint,
        MaxTask,
    }

    abstract class PaintTask
    {
        protected PaintCache m_Cache;

        protected PaintTask(PaintCache cache)
        {
            m_Cache = cache;
        }

        public virtual void Init()
        {
        }

        public abstract bool Run();

        public virtual void OnEnable()
        {
        }

        public virtual void OnDisable()
        {
        }

        public virtual void OnDestroy()
        {
        }
    }
}
