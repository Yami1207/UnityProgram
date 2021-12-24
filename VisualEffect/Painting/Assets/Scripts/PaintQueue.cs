using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    public class PaintParams
    {
        public delegate void OnExecPaint(PaintParams p);

        public int id;
        public bool processing = false;

        public GameObject target = null;

        public Vector3 position;
        public Quaternion rotation;
        public Vector3 forward;

        public OnExecPaint onExec;
        public System.Action<GameObject> onFinish;
    }

    public class PaintQueue
    {
        private readonly Queue<PaintParams> m_Queue;

        public PaintQueue()
        {
            m_Queue = new Queue<PaintParams>();
        }

        public void Enqueue(Vector3 pos, Quaternion rot, Vector3 forward, PaintParams.OnExecPaint execFunc, System.Action<GameObject> finishFunc)
        {
            var settings = new PaintParams()
            {
                position = pos,
                rotation = rot,
                forward = forward,
                onExec = execFunc,
                onFinish = finishFunc,
            };

            m_Queue.Enqueue(settings);
            ProcessQueue();
        }

        void ProcessQueue()
        {
            if (m_Queue.Count > 0)
            {
                var peek = m_Queue.Peek();
                if (!peek.processing)
                {
                    peek.id = Random.Range(int.MinValue, int.MaxValue);
                    peek.processing = true;
                    peek.onExec(peek);
                }
            }
        }

        public void OnPaintFinished(int id)
        {
            var paint = m_Queue.Dequeue();
            if (paint.onFinish != null)
                paint.onFinish.Invoke(paint.target);
            this.ProcessQueue();
        }
    }
}
