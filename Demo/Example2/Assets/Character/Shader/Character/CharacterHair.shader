Shader "Example/Character/Hair"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_SkinRamp("Skin Ramp", 2D) = "white" {}

		_SmoothFactor("Smooth Factor", Float) = 0.0133

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_SkinRate("Skin Rate", Float) = 0.3
		_SkinIntensity("Skin Intensity", Float) = 1.5
		[Linear]_SkinColor("Skin Color", Vector) = (1.0, 1.0, 1.0, 1)

		_FirstShadow("First Shadow", Float) = 0.51
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.56002, 0.55412, 0.55412, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.48653, 0.48653, 0.48653, 1)

		_SpecularShadowIntensity("Specular Shadow Intensity", Float) = 0.2888
		_SpecularIntensity("Specular Intensity", Float) = 0.45
		_SpecularShiness("Specular Shiness", Float) = 0.15
		[Linear]_SpecularColor("Specular Color", Vector) = (0.02029, 0.59234, 0.67244, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 0.0
		[Linear]_EmissionColor("Emission Color", Vector) = (0.0, 0.0, 0.0, 0)

		_RimMin("Rim Min", Float) = 0.661
		_RimMax("Rim Max", Float) = 0.846
		_RimIntensity("Rim Intensity", Float) = 1.15
		[Linear]_RimColor("Rim Color", Vector) = (0.3895, 0.37394, 0.87603, 1.0)
		_RimThreshold("Rim Threshold", Float) = 1
		_RimDistanceMin("Rim Distance Min", Float) = 5.0
		_RimDistanceMax("Rim Distance Max", Float) = 16.1

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.5
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.0

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_OutlineBloom("Outline Bloom", Float) = 0.295
		[Linear]_OutlineColor("Outline Color", Vector) = (0.13247, 0.14126, 0.17295, 1.00)

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

			#define USE_VERTEX_COLOR

			#include "CharacterHairPass.cginc"
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
			#define USE_VERTEX_COLOR
			#define USE_OFFSET_SCALE

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