using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DepthCamera : MonoBehaviour
{
    //[SerializeField]
    //private Light m_ShadowLight;

    [SerializeField]
    private float _XShadowNormalBias = 0.001f;

    private Camera m_Camera;

    private void Awake()
    {
        Camera camera = this.GetComponent<Camera>();
        if (camera == null || camera.targetTexture == null)
            return;

        m_Camera = camera;
        m_Camera.SetReplacementShader(Shader.Find("Hidden/Example/DepthOnly"), "RenderType");
    }

    private void Update()
    {
        Shader.SetGlobalFloat("_XShadowNormalBias", _XShadowNormalBias);

        if (m_Camera != null)
        {
            Shader.SetGlobalTexture("_XShadowTexture", m_Camera.targetTexture);
            Shader.SetGlobalVector("_XWorldSpaceShadowLightDir", m_Camera.transform.forward);

            Matrix4x4 worldToView = m_Camera.worldToCameraMatrix;
            Matrix4x4 projection = GL.GetGPUProjectionMatrix(m_Camera.projectionMatrix, false);
            Matrix4x4 lightProjecionMatrix = projection * worldToView;
            Shader.SetGlobalMatrix("_XShadowWorldToProj", lightProjecionMatrix);
        }
    }
}
