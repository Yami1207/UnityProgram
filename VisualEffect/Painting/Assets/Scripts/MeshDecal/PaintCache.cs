using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Painting
{
    public class PaintCache
    {
        public GameObject paintObject = null;

        public Vector3 paintPoint = Vector3.zero;
        public Vector3 paintSize = Vector3.one;

        public Matrix4x4 paintWorldToLocal = Matrix4x4.identity;

        public int paintLayer = 0;

        public float faceCullingOffset = 0.0f;
        public float positionOffset = 0.0f;

        public SceneMeshTree tree = null;

        // 保存创建Mesh数据
        public readonly List<Vector3> vertices = new List<Vector3>();
        public readonly List<Vector3> normals = new List<Vector3>();
        public readonly List<Vector2> texcoords = new List<Vector2>();
        public readonly List<int> indices = new List<int>();

        // 获取Mesh缓存数据
        public readonly List<Vector3> vertexPool = new List<Vector3>();
        public readonly List<int> indexPool = new List<int>();
        public readonly List<Vector3> polygonPool = new List<Vector3>();
    }
}
