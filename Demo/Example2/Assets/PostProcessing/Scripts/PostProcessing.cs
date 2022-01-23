using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class PostProcessing : MonoBehaviour
{
    [SerializeField]
    private Vector4 m_ConsoleSettings = new Vector4(0.33f, 8.00f, 0.25f, 0.06f);
    
    [SerializeField]
    private Vector4 m_UserLutParams = new Vector4(0.00098f, 0.03125f, 31.00f, 1.00f);

    [SerializeField]
    private Texture2D m_UserLutTex;

    private Material m_BlurMaterial;
    private Material m_FilterMaterial;
    private Material m_LutMaterial;

    private Material[] m_BloomMaterials;

    private void OnEnable()
    {
        // 模糊
        m_BlurMaterial = new Material(Shader.Find("Hidden/PostProcessing/Blur"));
        m_BlurMaterial.hideFlags = HideFlags.HideAndDontSave;

        // 过滤
        m_FilterMaterial = new Material(Shader.Find("Hidden/PostProcessing/Filter"));
        m_FilterMaterial.hideFlags = HideFlags.HideAndDontSave;
        m_FilterMaterial.SetFloat("_FilterScaler", 1.0f);
        m_FilterMaterial.SetFloat("_FilterThreshold", 0.3f);

        // Bloom
        m_BloomMaterials = new Material[4];
        m_BloomMaterials[0] = new Material(Shader.Find("Hidden/PostProcessing/Blur256"));
        m_BloomMaterials[0].hideFlags = HideFlags.HideAndDontSave;
        m_BloomMaterials[1] = new Material(Shader.Find("Hidden/PostProcessing/Blur128"));
        m_BloomMaterials[1].hideFlags = HideFlags.HideAndDontSave;
        m_BloomMaterials[2] = new Material(Shader.Find("Hidden/PostProcessing/SimpleBlur"));
        m_BloomMaterials[2].hideFlags = HideFlags.HideAndDontSave;
        m_BloomMaterials[3] = new Material(Shader.Find("Hidden/PostProcessing/MixBloom"));
        m_BloomMaterials[3].hideFlags = HideFlags.HideAndDontSave;
        m_BloomMaterials[3].SetVector("_BloomCombineCoeff", new Vector4(0.35f, 0.35f, 0.35f, 0.5f));

        // Lut
        m_LutMaterial = new Material(Shader.Find("Hidden/PostProcessing/Lut"));
        m_LutMaterial.hideFlags = HideFlags.HideAndDontSave;
        m_LutMaterial.SetVector("_ConsoleSettings", m_ConsoleSettings);
        m_LutMaterial.SetFloat("_Contrast", 1.8f);
        m_LutMaterial.SetFloat("_Exposure", 13.0f);
        m_LutMaterial.SetVector("_FinalBlendFactor", new Vector4(0.25f, 1.00f, 0.00f, 0.00f));
    }

    private void OnDisable()
    {
        if (m_BlurMaterial != null)
        {
            UnityEngine.Object.DestroyImmediate(m_BlurMaterial);
            m_BlurMaterial = null;
        }

        if (m_FilterMaterial != null)
        {
            UnityEngine.Object.DestroyImmediate(m_FilterMaterial);
            m_FilterMaterial = null;
        }

        if (m_LutMaterial != null)
        {
            UnityEngine.Object.DestroyImmediate(m_LutMaterial);
            m_LutMaterial = null;
        }

        if (m_BloomMaterials != null)
        {
            for (int i = 0; i < m_BloomMaterials.Length; ++i)
            {
                UnityEngine.Object.DestroyImmediate(m_BloomMaterials[i]);
                m_BloomMaterials[i] = null;
            }
            m_BloomMaterials = null;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int halfWidth = Screen.width >> 1, halfHeight = Screen.height >> 1;

        // 创建相关RT
        RenderTexture blurART = RenderTexture.GetTemporary(halfWidth, halfHeight, 0, RenderTextureFormat.ARGBHalf);
        RenderTexture blurBRT = RenderTexture.GetTemporary(halfWidth, halfHeight, 0, RenderTextureFormat.ARGBHalf);
        RenderTexture filterRT = RenderTexture.GetTemporary(256, 256, 0, RenderTextureFormat.ARGBHalf);
        // 处理模糊
        m_BlurMaterial.SetVector("_TexelSize", new Vector4(1.0f / halfWidth, 1.0f / halfHeight, 0.0f, 0.0f));
        m_BlurMaterial.EnableKeyword("FIRST_GAUSSIAN_BLUR");
        Graphics.Blit(source, blurART, m_BlurMaterial);
        m_BlurMaterial.DisableKeyword("FIRST_GAUSSIAN_BLUR");
        Graphics.Blit(blurART, blurBRT, m_BlurMaterial);

        // 过滤
        m_FilterMaterial.SetFloat("_FilterScaler", 1.0f);
        m_FilterMaterial.SetFloat("_FilterThreshold", 0.3f);
        Graphics.Blit(blurBRT, filterRT, m_FilterMaterial);

        // 处理Bloom
        RenderTexture[] bloomRT = new RenderTexture[4];
        bloomRT[0] = this.MixBloom(filterRT, 256, m_BloomMaterials[0]);
        bloomRT[1] = this.MixBloom(bloomRT[0], 128, m_BloomMaterials[1]);
        bloomRT[2] = this.MixBloom(bloomRT[1], 64, m_BloomMaterials[2]);
        bloomRT[3] = this.MixBloom(bloomRT[2], 32, m_BloomMaterials[2]);

        RenderTexture mixBloomRT = RenderTexture.GetTemporary(256, 256, 0, RenderTextureFormat.ARGBHalf);
        m_BloomMaterials[3].SetTexture("_BloomTex0", bloomRT[0]);
        m_BloomMaterials[3].SetTexture("_BloomTex1", bloomRT[1]);
        m_BloomMaterials[3].SetTexture("_BloomTex2", bloomRT[2]);
        m_BloomMaterials[3].SetTexture("_BloomTex3", bloomRT[3]);
        m_BloomMaterials[3].SetVector("_BloomCombineCoeff", new Vector4(0.35f, 0.35f, 0.35f, 0.5f));
        Graphics.Blit(bloomRT[3], mixBloomRT, m_BloomMaterials[3]);
        
        // 
        m_LutMaterial.SetTexture("_MainTex", source);
        m_LutMaterial.SetVector("_MainTex_TexelSize", new Vector4(1.0f / source.width, 1.0f / source.height, source.width, source.height));
        m_LutMaterial.SetTexture("_UserLut", m_UserLutTex);
        m_LutMaterial.SetVector("_UserLut_Params", new Vector4(1.0f / m_UserLutTex.width, 1.0f / m_UserLutTex.height, 31.00f, 1.00f));
        m_LutMaterial.SetTexture("_BloomTex", mixBloomRT);
        m_LutMaterial.SetVector("_ConsoleSettings", m_ConsoleSettings);
        m_LutMaterial.SetFloat("_Contrast", 1.8f);
        m_LutMaterial.SetFloat("_Exposure", 13.0f);
        m_LutMaterial.SetVector("_FinalBlendFactor", new Vector4(0.25f, 1.00f, 0.00f, 0.00f));
        m_LutMaterial.SetVector("_UserLut_Params", m_UserLutParams);
        Graphics.Blit(source, destination, m_LutMaterial);

        // 释放RT
        RenderTexture.ReleaseTemporary(blurART);
        RenderTexture.ReleaseTemporary(blurBRT);
        RenderTexture.ReleaseTemporary(filterRT);
        RenderTexture.ReleaseTemporary(mixBloomRT);
        for (int i = 0; i < bloomRT.Length; ++i)
            RenderTexture.ReleaseTemporary(bloomRT[i]);
    }

    private RenderTexture MixBloom(RenderTexture source, int size, Material material)
    {
        RenderTexture tempRT = RenderTexture.GetTemporary(size, size, 0, RenderTextureFormat.ARGBHalf);
        material.SetVector("_BlurDir", new Vector4(1.0f, 0.0f));
        Graphics.Blit(source, tempRT, material);

        RenderTexture resultRT = RenderTexture.GetTemporary(size, size, 0, RenderTextureFormat.ARGBHalf);
        material.SetVector("_BlurDir", new Vector4(0.0f, 1.0f));
        Graphics.Blit(tempRT, resultRT, material);

        // 释放RT
        RenderTexture.ReleaseTemporary(tempRT);

        return resultRT;
    }
}
