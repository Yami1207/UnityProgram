using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class HomeMain : MonoBehaviour
{
    [SerializeField]
    private Color m_SceneDarkColor = new Color(0.00f, 0.00f, 0.00f, 0.00f);

    [SerializeField]
    private float m_SceneGray = 0.0f;

    private void OnEnable()
    {
        Shader.SetGlobalVector("_G_LightDir", new Vector3(0.22368f, 0.51444f, -0.82784f));
        Shader.SetGlobalVector("_G_LightColor", new Vector4(1.30f, 1.30f, 1.30f, 1.0f));
        Shader.SetGlobalVector("_G_DynamicAmbientColor", new Vector4(1.19392f, 1.20851f, 1.27853f, 1.0f));
        Shader.SetGlobalVector("_G_SpecularColor", new Vector4(1.0f, 1.0f, 1.0f, 1.0f));

        Shader.SetGlobalVector("_G_CharacterLightDir", new Vector3(0.49594f, 0.5f, 0.70996f));
        Shader.SetGlobalVector("_G_TintColor", new Vector3(1.0f, 1.0f, 1.0f));
        Shader.SetGlobalVector("_G_CharacterAmbientColor", new Vector3(0.77195f, 0.78053f, 0.86765f));
        Shader.SetGlobalVector("_G_CharacterLightColor", new Vector3(2.0f, 2.0f, 2.0f));
        Shader.SetGlobalVector("_G_CharSpecularColor", new Vector3(1.0f, 1.0f, 1.0f));
        Shader.SetGlobalVector("_G_CharacterRimColor", new Vector3(1.0f, 1.0f, 1.0f));

        Shader.SetGlobalFloat("_G_CharacterShadowIntensity", 1.0f);
        Shader.SetGlobalVector("_G_CharacterNoShadowColor", new Vector3(0.85294f, 0.85294f, 0.85294f));
        Shader.SetGlobalVector("_G_CharacterOneShadowColor", new Vector3(1.0f, 1.0f, 1.0f));
        Shader.SetGlobalVector("_G_CharacterTwoShadowColor", new Vector3(0.78691f, 0.76476f, 0.90441f));

        Shader.SetGlobalFloat("_G_EnableDistanceRim", 0.0f);
        Shader.SetGlobalVector("_G_RimLightDir", new Vector3(0.7677f, 0.31782f, 0.55634f));

        Shader.SetGlobalVector("_G_SceneDarkColor", m_SceneDarkColor);
        Shader.SetGlobalFloat("_G_SceneGray", m_SceneGray);

        Shader.SetGlobalFloat("_G_PostBloom", 1.0f);
    }
}
