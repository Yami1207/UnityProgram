using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CSV2Mesh
{
    private struct CSVVertex
    {
        public int index;

        public Vector3 position;
        public Vector3 normal;
        public Vector4 tangent;
        public Color color;
        public Vector2 uv;
        public Vector2 uv1;

        public CSVVertex(int index, string[] data, Dictionary<string, int> dict)
        {
            this.index = index;

            // 顶点坐标
            position = Vector3.one;
            position.x = float.Parse(data[dict["POSITION.x"]]);
            position.y = float.Parse(data[dict["POSITION.y"]]);
            position.z = float.Parse(data[dict["POSITION.z"]]);

            // 法线
            normal = Vector3.up;
            if (dict.ContainsKey("NORMAL.x"))
            {
                normal.x = float.Parse(data[dict["NORMAL.x"]]);
                normal.y = float.Parse(data[dict["NORMAL.y"]]);
                normal.z = float.Parse(data[dict["NORMAL.z"]]);
            }

            // 切线
            tangent = Vector4.zero;
            if (dict.ContainsKey("in_TANGENT0.x"))
            {
                tangent.x = float.Parse(data[dict["in_TANGENT0.x"]]);
                tangent.y = float.Parse(data[dict["in_TANGENT0.y"]]);
                tangent.z = float.Parse(data[dict["in_TANGENT0.z"]]);
                tangent.w = float.Parse(data[dict["in_TANGENT0.z"]]);
            }

            // 顶点颜色
            color = Color.white;
            if (dict.ContainsKey("COLOR.x"))
            {
                color.r = float.Parse(data[dict["COLOR.x"]]);
                color.g = float.Parse(data[dict["COLOR.y"]]);
                color.b = float.Parse(data[dict["COLOR.z"]]);
                color.a = float.Parse(data[dict["COLOR.z"]]);
            }

            // uv
            uv = Vector2.zero;
            if (dict.ContainsKey("TEXCOORD0.x"))
            {
                uv.x = float.Parse(data[dict["TEXCOORD0.x"]]);
                uv.y = float.Parse(data[dict["TEXCOORD0.y"]]);
            }

            // uv1
            uv1 = Vector2.zero;
            if (dict.ContainsKey("TEXCOORD1.x"))
            {
                uv1.x = float.Parse(data[dict["TEXCOORD1.x"]]);
                uv1.y = float.Parse(data[dict["TEXCOORD1.y"]]);
            }
        }
    }

    [MenuItem("Assets/CSV To Mesh")]
    private static void ExecCSV2Mesh()
    {

        if (UnityEditor.Selection.activeObject == null)
            return;

        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (path == null)
            return;

        string[] lines = System.IO.File.ReadAllLines(path);
        if (lines.Length == 0)
            return;

        string parameterText = lines[0];
        string[] parmas = parameterText.Split(new char[1] { ',' }, System.StringSplitOptions.RemoveEmptyEntries);
        Dictionary<string, int> parameterDict = new Dictionary<string, int>();
        for (int i = 0; i < parmas.Length; ++i)
        {
            string parma = parmas[i];
            if (parma[0] == ' ')
                parma = parma.Substring(1);
            parameterDict.Add(parma, i);
        }

        Dictionary<int, int> vertexDict = new Dictionary<int, int>();
        List<CSVVertex> vertexList = new List<CSVVertex>();
        List<int> indexList = new List<int>();

        for (int i = 1; i < lines.Length; ++i)
        {
            string[] data = lines[i].Split(new char[1] { ',' }, System.StringSplitOptions.RemoveEmptyEntries);
            int key = int.Parse(data[parameterDict["IDX"]]);
            int vertexIndex = -1;
            if (!vertexDict.ContainsKey(key))
            {
                vertexIndex = vertexList.Count;

                CSVVertex vertex = new CSVVertex(vertexIndex, data, parameterDict);
                vertexList.Add(vertex);
                vertexDict.Add(key, vertexIndex);
            }
            else
            {
                vertexIndex = vertexDict[key];
            }
            indexList.Add(vertexIndex);
        }

        if (vertexList.Count == 0 || indexList.Count == 0)
            return;

        bool hasNormal = parameterDict.ContainsKey("NORMAL.x");
        bool hasTangent = parameterDict.ContainsKey("in_TANGENT0.x");
        bool hasColor = parameterDict.ContainsKey("COLOR.x");
        bool hasUV0 = parameterDict.ContainsKey("TEXCOORD0.x");
        bool hasUV1 = parameterDict.ContainsKey("TEXCOORD1.x");

        List<Vector3> vertexArray = new List<Vector3>();
        List<Vector3> normalArray = new List<Vector3>();
        List<Vector4> tangentArray = new List<Vector4>();
        List<Color> colorArray = new List<Color>();
        List<Vector2> uv0Array = new List<Vector2>();
        List<Vector2> uv1Array = new List<Vector2>();
        List<Vector2> uv3Array = new List<Vector2>();

        for (int i = 0; i < vertexList.Count; ++i)
        {
            vertexArray.Add(vertexList[i].position);
            if (hasNormal) normalArray.Add(vertexList[i].normal);
            if (hasTangent) tangentArray.Add(vertexList[i].tangent);
            if (hasColor) colorArray.Add(vertexList[i].color);
            if (hasUV0) uv0Array.Add(vertexList[i].uv);
            if (hasUV1) uv1Array.Add(vertexList[i].uv1);
        }

        int numTriangles = (int)(indexList.Count / 3);
        int[] triangles = new int[indexList.Count];
        for (int i = 0; i < numTriangles; ++i)
        {
            int index = i * 3;
            triangles[index] = indexList[index];
            triangles[index + 1] = indexList[index + 1];
            triangles[index + 2] = indexList[index + 2];
        }

        Mesh mesh = new Mesh();
        mesh.SetVertices(vertexArray);
        if (hasNormal) mesh.SetNormals(normalArray);
        if (hasTangent) mesh.SetTangents(tangentArray);
        if (hasColor) mesh.SetColors(colorArray);
        if (hasUV0) mesh.SetUVs(0, uv0Array);
        if (hasUV1) mesh.SetUVs(1, uv1Array);
        mesh.SetTriangles(triangles, 0);
        mesh.RecalculateBounds();

        int pos = path.LastIndexOf('/');
        string dir = path.Substring(0, pos);
        string name = path.Substring(pos + 1);
        name = name.Substring(0, name.LastIndexOf('.'));
        AssetDatabase.CreateAsset(mesh, string.Format("{0}/{1}.asset", dir, name));
    }
}
