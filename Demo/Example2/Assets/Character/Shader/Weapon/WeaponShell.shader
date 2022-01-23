Shader "Example/Weapon/Shell"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "black" {}
		_CubeMap("Cube Map", CUBE) = "" {}

		_BumpScale("Bump Scale", Float) = 2.0

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_Roughness("Roughness", Float) = 0.647
		_Metallic("Metallic", Float) = 0.67

		_PBRRate("PBR Rate", Float) = 0.11
		_SmoothFactor("Smooth Factor", Float) = 0.013

		[Linear]_DirectLightColor("Direct Light Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_IndirectLightIntensity("Indirect Light Intensity", Float) = 1.0
		[Linear]_IndirectLightColor("Indirect Light Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_PBRSpecularIntensity("PBR Specular Intensity", Float) = 1.0
		[Linear]_PBRSpecularColor("PBR Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_CubemapIntensity("Cubemap Intensity", Float) = 1.0
		[Linear]_CubemapColor("Cubemap Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_FirstShadow("First Shadow", Float) = 0.6
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.58164, 0.55327, 0.57728, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.06686, 0.06686, 0.06686, 1)

		_SpecularIntensity("Specular Intensity", Float) = 0.2
		_SpecularShiness("Specular Shiness", Float) = 9.5
		[Linear]_SpecularColor("Specular Color", Vector) = (0.85601, 0.75953, 0.75953, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 6.46
		[Linear]_EmissionColor("Emission Color", Vector) = (1.0, 0.0, 0.93839, 0)

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.01
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.5

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.12577, 0.12383, 0.12383, 0.30)

		[Linear]_MeshShadowColor("Mesh Shadow Color", Vector) = (1.00, 1.00, 1.00, 1.00)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Name "ForwardBase"
			Tags{ "LightMode" = "ForwardBase" }

			Cull off
			Blend off//SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			// -------------------------------------
			// 自定义宏
			#define L_PBR_ON
			#define SHADOW_SMOOTH_ON

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
