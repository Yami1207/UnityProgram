using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    class PostPaint : PaintTask
    {
        public PostPaint(PaintCache cache) : base(cache)
        {
        }

        public override bool Run()
        {
            // 显示Mesh
            if (m_Cache.paintObject != null)
            {
                MeshRenderer renderer = m_Cache.paintObject.GetComponent<MeshRenderer>();
                if (renderer != null) renderer.enabled = true;
            }

            return true;
        }
    }
}
