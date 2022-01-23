using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GroundReflectionRT : MonoBehaviour
{
    private static readonly int REFLECTION_TEX_PROP_ID = Shader.PropertyToID("_G_GroundReflectionTex");

    [SerializeField]
    [Range(0.01f, 0.2f)]
    private float m_ClipPlaneOffset = 0.07f;

    [SerializeField]
    private LayerMask m_ReflectionLayer = 0;

    private Dictionary<Camera, Camera> m_ReflectionCameras = new Dictionary<Camera, Camera>();

    private RenderTexture m_ReflectionTex;

    private void OnDisable()
    {
        if (m_ReflectionTex != null)
        {
            RenderTexture.ReleaseTemporary(m_ReflectionTex);
            m_ReflectionTex = null;
        }
    }

    private void OnWillRenderObject()
    {
        Camera currentCamera = Camera.current;
        if (currentCamera == null) return;

        // 创建RT图
        if (m_ReflectionTex == null)
            m_ReflectionTex = RenderTexture.GetTemporary(512, 512);

        Camera reflectionCamera = null;
        if (m_ReflectionCameras.ContainsKey(currentCamera))
        {
            reflectionCamera = m_ReflectionCameras[currentCamera];
        }
        else
        {
            GameObject newCamera = new GameObject("Reflection Camera");
            newCamera.hideFlags = HideFlags.HideAndDontSave;
            reflectionCamera = newCamera.AddComponent<Camera>();
            reflectionCamera.enabled = false;
            reflectionCamera.cullingMask = m_ReflectionLayer;

            m_ReflectionCameras.Add(currentCamera, reflectionCamera);
        }

        this.CloneCamera(currentCamera, reflectionCamera);

        // 反射平面
        Vector3 pos = transform.position, normal = transform.up;
        float d = -Vector3.Dot(normal, pos) - m_ClipPlaneOffset;
        Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

        // 计算反射矩阵
        Matrix4x4 reflection = Matrix4x4.zero;
        this.CalculateReflectionMatrix(ref reflection, reflectionPlane);

        reflectionCamera.worldToCameraMatrix = currentCamera.worldToCameraMatrix * reflection;
        Vector4 clipPlane = this.CameraSpacePlane(reflectionCamera, pos, normal, 1.0f);
        reflectionCamera.projectionMatrix = currentCamera.CalculateObliqueMatrix(clipPlane);

        reflectionCamera.targetTexture = m_ReflectionTex;
        bool oldCulling = GL.invertCulling;
        GL.invertCulling = !GL.invertCulling;
        reflectionCamera.Render();
        GL.invertCulling = oldCulling;

        Shader.SetGlobalTexture(REFLECTION_TEX_PROP_ID, m_ReflectionTex);
    }

    private void OnValidate()
    {
        foreach (var camera in m_ReflectionCameras)
        {
            camera.Value.cullingMask = m_ReflectionLayer;
        }
    }

    private void CloneCamera(Camera src, Camera dest)
    {
        dest.clearFlags = src.clearFlags;
        dest.backgroundColor = Color.black;//src.backgroundColor;
        dest.farClipPlane = src.farClipPlane;
        dest.nearClipPlane = src.nearClipPlane;
        dest.orthographic = src.orthographic;
        dest.fieldOfView = src.fieldOfView;
        dest.aspect = src.aspect;
        dest.orthographicSize = src.orthographicSize;
    }

    /// <summary>
    /// 计算出摄像机空间下反射平面
    /// </summary>
    /// <param name="cam"></param>
    /// <param name="pos"></param>
    /// <param name="normal"></param>
    /// <param name="sideSign"></param>
    /// <returns></returns>
    private Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign)
    {
        Vector3 offsetPos = pos + normal * m_ClipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));
    }

    /// <summary>
    /// 计算反射矩阵
    /// 可参考：https://www.cnblogs.com/wantnon/p/5630915.html
    /// </summary>
    /// <param name="reflectionMat"></param>
    /// <param name="plane"></param>
    private void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
    }
}
