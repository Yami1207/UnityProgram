using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    static class Utility
    {
        /// <summary>
        /// 排序多边形顶点
        /// </summary>
        private class PolygonPointComparer : IComparer<Vector3>
        {
            private Vector3 m_Origin;
            private Vector3 m_Normal;

            public PolygonPointComparer(Vector3 o, Vector3 n)
            {
                m_Origin = o;
                m_Normal = n;
            }

            public int Compare(Vector3 left, Vector3 right)
            {
                Vector3 n = Vector3.Cross(left - m_Origin, right - m_Origin);
                float d = Vector3.Dot(-m_Normal, n);
                return d < 0 ? -1 : d > 0 ? 1 : 0;
            }
        }

        public struct Rect3D
        {
            public Vector3[] points;
            public Vector3 normal;
        }

        private static Bounds s_Bounds = new Bounds(Vector3.zero, Vector3.one);

        private static Rect3D UP = new Rect3D()
        {
            points = new Vector3[4] {
                new Vector3(-0.5f, 0.5f, -0.5f),
                new Vector3(0.5f, 0.5f, -0.5f),
                new Vector3(0.5f, 0.5f, 0.5f),
                new Vector3(-0.5f, 0.5f, 0.5f),
            },
            normal = Vector3.up,
        };

        private static Rect3D DOWM = new Rect3D()
        {
            points = new Vector3[4] {
                new Vector3(-0.5f, -0.5f, -0.5f),
                new Vector3(-0.5f, -0.5f, 0.5f),
                new Vector3(0.5f, -0.5f, 0.5f),
                new Vector3(0.5f, -0.5f, -0.5f),
            },
            normal = Vector3.down,
        };

        private static Rect3D LEFT = new Rect3D()
        {
            points = new Vector3[4] {
                new Vector3(-0.5f, -0.5f, -0.5f),
                new Vector3(-0.5f, 0.5f, -0.5f),
                new Vector3(-0.5f, 0.5f, 0.5f),
                new Vector3(-0.5f, -0.5f, 0.5f),
            },
            normal = Vector3.left,
        };

        private static Rect3D RIGHT = new Rect3D()
        {
            points = new Vector3[4] {
                new Vector3(0.5f, -0.5f, -0.5f),
                new Vector3(0.5f, -0.5f, 0.5f),
                new Vector3(0.5f, 0.5f, 0.5f),
                new Vector3(0.5f, 0.5f, -0.5f),
            },
            normal = Vector3.right,
        };

        private static Rect3D FORWARD = new Rect3D()
        {
            points = new Vector3[4] {
                new Vector3(-0.5f, -0.5f, 0.5f),
                new Vector3(-0.5f, 0.5f, 0.5f),
                new Vector3(0.5f, 0.5f, 0.5f),
                new Vector3(0.5f, -0.5f, 0.5f),
            },
            normal = Vector3.forward,
        };

        private static Rect3D BACK = new Rect3D()
        {
            points = new Vector3[4] {
                new Vector3(-0.5f, -0.5f, -0.5f),
                 new Vector3(0.5f, -0.5f, -0.5f),
                new Vector3(0.5f, 0.5f, -0.5f),
                new Vector3(-0.5f, 0.5f, -0.5f),
            },
            normal = Vector3.back,
        };

        /// <summary>
        /// 检测三角形与立方体是否相交，并将相交点放进polygon列表
        /// </summary>
        /// <param name="v1"></param>
        /// <param name="v2"></param>
        /// <param name="v3"></param>
        /// <param name="polygon"></param>
        public static void TestIntersect(Vector3 v1, Vector3 v2, Vector3 v3, List<Vector3> polygon)
        {
            Vector3 n = Vector3.Cross(v1 - v2, v1 - v3).normalized;
            Plane triangle = new Plane(n, Vector3.Dot(v1, n));
            if (!TestAABBPlane(s_Bounds, triangle))
                return;

            if (s_Bounds.Contains(v1)) polygon.Add(v1);
            if (s_Bounds.Contains(v2)) polygon.Add(v2);
            if (s_Bounds.Contains(v3)) polygon.Add(v3);

            // 三角形都在AABB内就不需要进行剪切
            if (polygon.Count == 3)
                return;

            // 进行剪切三角形
            IntersectTriangleRect(v1, v2, v3, triangle, ref UP, polygon);
            IntersectTriangleRect(v1, v2, v3, triangle, ref DOWM, polygon);
            IntersectTriangleRect(v1, v2, v3, triangle, ref LEFT, polygon);
            IntersectTriangleRect(v1, v2, v3, triangle, ref RIGHT, polygon);
            IntersectTriangleRect(v1, v2, v3, triangle, ref FORWARD, polygon);
            IntersectTriangleRect(v1, v2, v3, triangle, ref BACK, polygon);

            if (polygon.Count < 3)
                return;

            // 顶点排序
            polygon.Sort(1, polygon.Count - 1, new PolygonPointComparer(polygon[0], triangle.normal));
        }

        /// <summary>
        /// 检测包围盒与平面是否相交
        /// </summary>
        /// <param name="bounds"></param>
        /// <param name="plane"></param>
        /// <returns></returns>
        public static bool TestAABBPlane(Bounds bounds, Plane plane)
        {
            Vector3 minBounds = bounds.min, maxBounds = bounds.max;
            Vector3 min = Vector3.zero, max = Vector3.zero;
            if (plane.normal.x >= 0.0f)
            {
                min.x = minBounds.x;
                max.x = maxBounds.x;
            }
            else
            {
                min.x = maxBounds.x;
                max.x = minBounds.x;
            }

            if (plane.normal.y >= 0.0f)
            {
                min.y = minBounds.y;
                max.y = maxBounds.y;
            }
            else
            {
                min.y = maxBounds.y;
                max.y = minBounds.y;
            }

            if (plane.normal.z >= 0.0f)
            {
                min.z = minBounds.z;
                max.z = maxBounds.z;
            }
            else
            {
                min.z = maxBounds.z;
                max.z = minBounds.z;
            }

            if (plane.GetDistanceToPoint(min) > 0.0f)
                return false;
            if (plane.GetDistanceToPoint(max) >= 0.0f)
                return true;
            return false;
        }

        /// <summary>
        /// 检测三角形与矩形是否相交
        /// </summary>
        /// <param name="v1"></param>
        /// <param name="v2"></param>
        /// <param name="v3"></param>
        /// <param name="triangle"></param>
        /// <param name="rect"></param>
        /// <param name="polygon"></param>
        public static void IntersectTriangleRect(Vector3 v1, Vector3 v2, Vector3 v3, Plane triangle, ref Rect3D rect, List<Vector3> polygon)
        {
            // 判断三角形与矩形所在的平面是否相交
            Plane plane = new Plane(rect.normal, Vector3.Dot(rect.points[0], rect.normal));
            Vector3 p = Vector3.zero, dir = Vector3.zero;
            if (!IntersectPlanes(triangle, plane, ref p, ref dir))
                return;

            // 获取三角形与相交线的交点
            List<Vector3> triPoints = new List<Vector3>();
            IntersectLines(v1, v2, p, p + dir, triPoints);
            IntersectLines(v2, v3, p, p + dir, triPoints);
            IntersectLines(v3, v1, p, p + dir, triPoints);
            if (triPoints.Count == 0)
                return;

            // 获取矩形平面与相交线的交点
            List<Vector3> rectPoints = new List<Vector3>();
            for (int i = 0; i < rect.points.Length; ++i)
            {
                int next = (i + 1) % rect.points.Length;
                IntersectLines(rect.points[i], rect.points[next], p, p + dir, rectPoints);
            }
            if (rectPoints.Count == 0)
                return;

            Vector2 triArea = new Vector2(float.MaxValue, float.MinValue);
            for (int i = 0; i < triPoints.Count; ++i)
            {
                float t = Vector3.Dot(triPoints[i] - p, dir);
                triArea.x = Mathf.Min(triArea.x, t);
                triArea.y = Mathf.Max(triArea.y, t);
            }

            Vector2 rectArea = new Vector2(float.MaxValue, float.MinValue);
            for (int i = 0; i < rectPoints.Count; ++i)
            {
                float t = Vector3.Dot(rectPoints[i] - p, dir);
                rectArea.x = Mathf.Min(rectArea.x, t);
                rectArea.y = Mathf.Max(rectArea.y, t);
            }

            if (triArea.x > rectArea.y || triArea.y < rectArea.x)
                return;

            float t0 = triArea.x >= rectArea.x ? triArea.x : rectArea.x;
            float t1 = triArea.y <= rectArea.y ? triArea.y : rectArea.y;
            if (Mathf.Abs(t0 - t1) < Mathf.Epsilon)
            {
                Vector3 point = p + t0 * dir;
                if (FindVertex(point, polygon) == -1)
                    polygon.Add(point);
            }
            else
            {
                Vector3 point = p + t0 * dir;
                if (FindVertex(point, polygon) == -1)
                    polygon.Add(point);

                point = p + t1 * dir;
                if (FindVertex(point, polygon) == -1)
                    polygon.Add(point);
            }
        }

        /// <summary>
        /// 检测两平面是否相交
        /// </summary>
        /// <param name="p1"></param>
        /// <param name="p2"></param>
        /// <param name="p"></param>
        /// <param name="dir"></param>
        /// <returns></returns>
        public static bool IntersectPlanes(Plane p1, Plane p2, ref Vector3 p, ref Vector3 dir)
        {
            dir = Vector3.Cross(p1.normal, p2.normal).normalized;
            if (Vector3.Dot(dir, dir) < Mathf.Epsilon) return false;

            float d11 = Vector3.Dot(p1.normal, p1.normal);
            float d12 = Vector3.Dot(p1.normal, p2.normal);
            float d22 = Vector3.Dot(p2.normal, p2.normal);

            float denom = d11 * d22 - d12 * d12;
            float k1 = (p1.distance * d22 - p2.distance * d12) / denom;
            float k2 = (p2.distance * d11 - p1.distance * d12) / denom;
            p = k1 * p1.normal + k2 * p2.normal;
            return true;
        }

        /// <summary>
        /// 判断两直线是否相交（此函数只能用在两直线所在同一平面上）
        /// </summary>
        /// <param name="v1"></param>
        /// <param name="v2"></param>
        /// <param name="v3"></param>
        /// <param name="v4"></param>
        /// <param name="intersects"></param>
        private static void IntersectLines(Vector3 v1, Vector3 v2, Vector3 v3, Vector3 v4, List<Vector3> intersects)
        {
            Vector3 e12 = v2 - v1, e34 = v4 - v3;
            Vector3 n12 = Vector3.Cross(e12, e34);

            // 两直线是否平行或重合
            float dot = Vector3.Dot(n12, n12);
            if (dot <= Mathf.Epsilon)
            {
                // 两直线重合
                if (Mathf.Abs(Vector3.Dot(v3 - v1, e34)) <= Mathf.Epsilon)
                {
                    intersects.Add(v1);
                    intersects.Add(v2);
                }

                return;
            }

            float t = Vector3.Dot(Vector3.Cross(v3 - v1, e34), n12) / dot;
            if (t >= 0.0f && t <= 1.0f)
                intersects.Add(v1 + t * e12);
        }

        /// <summary>
        /// 判断输入顶点是否存在列表中，如果存在返回列表索引，反之返回-1
        /// </summary>
        /// <param name="vertex"></param>
        /// <param name="vertices"></param>
        /// <returns></returns>
        public static int FindVertex(Vector3 vertex, List<Vector3> vertices)
        {
            for (int i = 0; i < vertices.Count; ++i)
            {
                if (Vector3.Distance(vertex, vertices[i]) < 0.01f)
                    return i;
            }

            return -1;
        }
    }
}
