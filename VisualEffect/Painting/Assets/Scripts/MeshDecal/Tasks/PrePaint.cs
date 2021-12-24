using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    class PrePaint : PaintTask
    {
        public PrePaint(PaintCache cache) : base(cache)
        {
        }

        public override void Init()
        {
            if (m_Cache.paintObject != null)
            {
                MeshRenderer renderer = m_Cache.paintObject.GetComponent<MeshRenderer>();
                if (renderer != null) renderer.enabled = false;
            }
        }

        public override bool Run()
        {
            return true;
        }
    }
}
