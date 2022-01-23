Shader "Example/Character/Body"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "black" {}
		_SkinRamp("Skin Ramp", 2D) = "white" {}

		_BumpScale("Bump Scale", Float) = 1.0

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_SkinRate("Skin Rate", Float) = 0.15
		_SkinIntensity("Skin Intensity", Float) = 1.0
		[Linear]_SkinColor("Skin Color", Vector) = (1.0, 1.0, 1.0, 1)

		_FirstShadow("First Shadow", Float) = 0.51
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.7454, 0.57405, 0.57405, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.7454, 0.57113, 0.57113, 1)

		_SpecularIntensity("Specular Intensity", Float) = 0.0
		_SpecularShiness("Specular Shiness", Float) = 8.0
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 0.0
		[Linear]_EmissionColor("Emission Color", Vector) = (0.0, 0.0, 0.0, 0)

		_RimMin("Rim Min", Float) = 0.75
		_RimMax("Rim Max", Float) = 0.76
		_RimIntensity("Rim Intensity", Float) = 0.2
		[Linear]_RimColor("Rim Color", Vector) = (1.0, 1.0, 1.0, 1.0)
		_RimThreshold("Rim Threshold", Float) = 1.0
		_RimDistanceMin("Rim Distance Min", Float) = 8.0
		_RimDistanceMax("Rim Distance Max", Float) = 20

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.04
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.0

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (0.9184, 0.70961, 0.6662, 0.0)

		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.09441, 0.04062, 0.04062, 1.00)

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
			Blend off//SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#define USE_VERTEX_COLOR
			#define USE_SHADOWMAP
			#define USE_NORMAL_MAP

			#include "CharacterPass.cginc"
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
