Shader "Example/Equip/Clothe"
{
    Properties
    {
		_BaseTex("Albedo", 2D) = "white" {}
		_PBRMask("PBR Mask(R: 粗糙度 G: 金属度 B: AO  A:PBR区域)", 2D) = "white" {}
		_DetailMap("Detail Map", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "black" {}
		_CubeMap("Cube Map", CUBE) = "" {}

		_AOScale("AO Scale", Float) = 1.0
		_BumpScale("Bump Scale", Float) = 1.0
		_MetallicMapScale("Metallic Map Scale", Float) = 1.0
		_RoughnessMapScale("Roughness Map Scale", Float) = 1.0

		_SmoothFactor("Smooth Factor", Float) = 0.016

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		[Linear]_DirectLightColor("Direct Light Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_IndirectLightIntensity("Indirect Light Intensity", Float) = 1.0
		[Linear]_IndirectLightColor("Indirect Light Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_PBRRate("PBR Rate", Float) = 1.0
		_PBRSpecularIntensity("PBR Specular Intensity", Float) = 0.2
		[Linear]_PBRSpecularColor("PBR Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_CubemapIntensity("Cubemap Intensity", Float) = 3.0
		[Linear]_CubemapColor("Cubemap Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_FirstShadow("First Shadow", Float) = 0.51
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.34562, 0.33493, 0.33493, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.3467, 0.33716, 0.33716, 1)

		_SpecularIntensity("Specular Intensity", Float) = 2
		_SpecularShiness("Specular Shiness", Float) = 5
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 2.0
		_EmissionColor("Emission Color", Vector) = (1.0, 0.52252, 0.95694, 0)

		_RimMin("Rim Min", Float) = 0.647
		_RimMax("Rim Max", Float) = 0.661
		_RimIntensity("Rim Intensity", Float) = 0.15
		[Linear]_RimColor("Rim Color", Vector) = (0.57398, 0.65827, 0.95761, 1.0)
		_RimThreshold("Rim Threshold", Float) = 1
		_RimDistanceMin("Rim Distance Min", Float) = 8.0
		_RimDistanceMax("Rim Distance Max", Float) = 11.0

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.06
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 3.0

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.0, 0.0, 0.0, 0.30)

		[Linear]_MeshShadowColor("Mesh Shadow Color", Vector) = (1.00, 1.00, 1.00, 1.00)
    }
    SubShader
    {
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Name "ForwardBase"
			Tags{ "LightMode" = "ForwardBase" }

			Cull off
			Blend off
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			// -------------------------------------
			// 自定义宏
			#define USE_VERTEX_COLOR
			#define USE_UV1
			#define L_PBR_ON
			#define L_AO_ON
			#define SHADOW_SMOOTH_ON

			#include "EquipBasePass.cginc"
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

			#define USE_VERTEX_COLOR
			#define USE_TBN

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
