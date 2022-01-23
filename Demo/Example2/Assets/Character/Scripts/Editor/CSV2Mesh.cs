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
        public Vector3 uv3;

        public CSVVertex(int index, string[] data, Dictionary<string, int> dict)
        {
            this.index = index;

            position = Vector3.one;
            position.x = float.Parse(data[dict["in_POSITION0.x"]]);
            position.y = float.Parse(data[dict["in_POSITION0.y"]]);
            position.z = float.Parse(data[dict["in_POSITION0.z"]]);

            normal = Vector3.up;
            if (dict.ContainsKey("in_NORMAL0.x"))
            {
                normal.x = float.Parse(data[dict["in_NORMAL0.x"]]);
                normal.y = float.Parse(data[dict["in_NORMAL0.y"]]);
                normal.z = float.Parse(data[dict["in_NORMAL0.z"]]);
            }

            tangent = Vector4.zero;
            if (dict.ContainsKey("in_TANGENT0.x"))
            {
                tangent.x = float.Parse(data[dict["in_TANGENT0.x"]]);
                tangent.y = float.Parse(data[dict["in_TANGENT0.y"]]);
                tangent.z = float.Parse(data[dict["in_TANGENT0.z"]]);
                tangent.w = float.Parse(data[dict["in_TANGENT0.z"]]);
            }

            color = Color.white;
            if (dict.ContainsKey("in_COLOR0.x"))
            {
                color.r = float.Parse(data[dict["in_COLOR0.x"]]);
                color.g = float.Parse(data[dict["in_COLOR0.y"]]);
                color.b = float.Parse(data[dict["in_COLOR0.z"]]);
                color.a = float.Parse(data[dict["in_COLOR0.z"]]);
            }

            uv = Vector2.zero;
            if (dict.ContainsKey("in_TEXCOORD0.x"))
            {
                uv.x = float.Parse(data[dict["in_TEXCOORD0.x"]]);
                uv.y = float.Parse(data[dict["in_TEXCOORD0.y"]]);
            }

            uv1 = Vector2.zero;
            if (dict.ContainsKey("in_TEXCOORD1.x"))
            {
                uv1.x = float.Parse(data[dict["in_TEXCOORD1.x"]]);
                uv1.y = float.Parse(data[dict["in_TEXCOORD1.y"]]);
            }

            uv3 = Vector3.one;
            if (dict.ContainsKey("in_TEXCOORD3.x"))
            {
                uv3.x = float.Parse(data[dict["in_TEXCOORD3.x"]]);
                uv3.y = float.Parse(data[dict["in_TEXCOORD3.y"]]);
                uv3.z = float.Parse(data[dict["in_TEXCOORD3.z"]]);
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

        bool hasNormal = parameterDict.ContainsKey("in_NORMAL0.x");
        bool hasTangent = parameterDict.ContainsKey("in_TANGENT0.x");
        bool hasColor = parameterDict.ContainsKey("in_COLOR0.x");
        bool hasUV0 = parameterDict.ContainsKey("in_TEXCOORD0.x");
        bool hasUV1 = parameterDict.ContainsKey("in_TEXCOORD1.x");
        bool hasUV3 = parameterDict.ContainsKey("in_TEXCOORD3.x");

        //Vector3[] vertexArray = new Vector3[vertexList.Count];
        //Vector3[] normalArray = new Vector3[vertexList.Count];
        //Vector4[] tangentArray = new Vector4[vertexList.Count];
        //Color[] colorArray = new Color[vertexList.Count];
        //Vector2[] uv0Array = new Vector2[vertexList.Count];
        //Vector2[] uv1Array = new Vector2[vertexList.Count];
        //Vector3[] uv3Array = new Vector3[vertexList.Count];
        List<Vector3> vertexArray = new List<Vector3>();
        List<Vector3> normalArray = new List<Vector3>();
        List<Vector4> tangentArray = new List<Vector4>();
        List<Color> colorArray = new List<Color>();
        List<Vector2> uv0Array = new List<Vector2>();
        List<Vector2> uv1Array = new List<Vector2>();
        List<Vector2> uv3Array = new List<Vector2>();

        for (int i = 0; i < vertexList.Count; ++i)
        {
            //vertexArray[i] = vertexList[i].position;
            //normalArray[i] = vertexList[i].normal;
            //if (hasTangent) tangentArray[i] = vertexList[i].tangent;
            //if (hasColor) colorArray[i] = vertexList[i].color;
            //uv0Array[i] = vertexList[i].uv;
            //if (hasUV1) uv1Array[i] = vertexList[i].uv1;
            //if (hasUV3) uv3Array[i] = vertexList[i].uv3;
            vertexArray.Add(vertexList[i].position);
            if (hasNormal) normalArray.Add(vertexList[i].normal);
            if (hasTangent) tangentArray.Add(vertexList[i].tangent);
            if (hasColor) colorArray.Add(vertexList[i].color);
            if (hasUV0) uv0Array.Add(vertexList[i].uv);
            if (hasUV1) uv1Array.Add(vertexList[i].uv1);
            if (hasUV3) uv3Array.Add(vertexList[i].uv3);
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
        if (hasUV3) mesh.SetUVs(3, uv3Array);
        mesh.SetTriangles(triangles, 0);
        mesh.RecalculateBounds();

        int pos = path.LastIndexOf('/');
        string dir = path.Substring(0, pos);
        string name = path.Substring(pos + 1);
        name = name.Substring(0, name.LastIndexOf('.'));
        AssetDatabase.CreateAsset(mesh, string.Format("{0}/{1}.asset", dir, name));
    }
}
