Shader "Example/Weapon/Inside"
{
    Properties
    {
        _BaseTex ("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "black" {}

		_BumpScale("Bump Scale", Float) = 1.0

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_FirstShadow("First Shadow", Float) = 0.51
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.48881, 0.48881, 0.48881, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.15218, 0.15218, 0.15218, 1)

		_SpecularIntensity("Specular Intensity", Float) = 1.6
		_SpecularShiness("Specular Shiness", Float) = 42.3
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 4.01
		[Linear]_EmissionColor("Emission Color", Vector) = (1.0, 0.0, 0.85023, 0)

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.02
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.5

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.48
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.07768, 0.0687, 0.0759, 0.30)

		[Linear]_MeshShadowColor("Mesh Shadow Color", Vector) = (1.00, 1.00, 1.00, 1.00)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Name "ForwardBase"
			Tags{ "LightMode" = "ForwardBase" }

			Cull off
			//Blend SrcAlpha OneMinusSrcAlpha
			Blend Off
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "WeaponPass.cginc"
			ENDCG
        }

		Pass
		{
			Name "Outline"

			Cull front
			Blend off
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "../Pass/OutlinePass.cginc"
			ENDCG
		}

		Pass
		{
			Name "Shadow"

			Cull back
			Blend One Zero
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "../Pass/ShadowPass.cginc"
			ENDCG
		}
    }
}
