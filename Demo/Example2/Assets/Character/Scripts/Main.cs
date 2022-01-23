using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Main : MonoBehaviour
{
    [SerializeField]
    private float m_CharOutlineWidth = 2.0f;

    //[SerializeField]
    //private Texture2D m_Shadowmap;

    private void OnEnable()
    {
        Shader.SetGlobalVector("_GlobalRimLightDir", new Vector4(-0.89284f, 0.4501f, -0.01558f, 0.0f));
        Shader.SetGlobalFloat("_GlobalEnableDistanceRim", 0.0f);

        Shader.SetGlobalColor("_GlobalTint", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalFloat("_XPostBloom", 1.0f);

        Shader.SetGlobalVector("_XGlobalCharacterLightDir", new Vector4(0.00012f, 0.50f, -0.86603f, 0.0f));
        Shader.SetGlobalColor("_XGlobalCharacterLightColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));

        Shader.SetGlobalColor("_XGlobalCharacterAmbientColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalColor("_XGlobalCharSpecularColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));

        Shader.SetGlobalColor("_XGlobalCharacterNoShadowColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalColor("_XGlobalCharacterOneShadowColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalColor("_XGlobalCharacterTwoShadowColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));

        Shader.SetGlobalColor("_XGlobalCharacterSkinNoShadowColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalColor("_XGlobalCharacterSkinOneShadowColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalColor("_XGlobalCharacterSkinTwoShadowColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalColor("_XGlobalCharacterSkinRimColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));

        Shader.SetGlobalColor("_XGlobalCharOutlineColor", new Color(1.0f, 1.0f, 1.0f, 1.0f));
        Shader.SetGlobalFloat("_XOutlineBrightness", 1.0f);
        Shader.SetGlobalFloat("_XCharOutlineWidth", m_CharOutlineWidth);
        Shader.SetGlobalFloat("_XOutlineZMaxOffset", 0.2f);
        Shader.SetGlobalFloat("_XOutlineDitanceScale", 0.015f);
        Shader.SetGlobalFloat("_XOutlineZOffset", 0.0f);

        Shader.SetGlobalFloat("_XShadowNormalBias", 0.001f);
        Shader.SetGlobalFloat("_XShadowOffset", 0.003f);

        Shader.SetGlobalFloat("_GlobalShadowHeight", 0.0f);
        Shader.SetGlobalFloat("_GlobalShadowIntensity", 0.55f);
        Shader.SetGlobalVector("_XShadowDir", new Vector4(0.45754f, 0.70711f, -0.53913f));
    }

    private void Update()
    {
        Shader.SetGlobalFloat("_XCharOutlineWidth", m_CharOutlineWidth);
    }
}
