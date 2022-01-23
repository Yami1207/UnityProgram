Shader "Example/Equip/Skirt"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "black" {}
		_MatCapTex("MatCap Map", 2D) = "white" {}

		_BumpScale("Bump Scale", Float) = 1.0

		_MatCapYScale("MatCap Y Scale", Float) = 0.3
		_SmoothFactor("Smooth Factor", Float) = 0.0276

		[Linear]_AlbedoColor("Albedo Color", Vector) = (0.92222, 0.92222, 0.92222, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_FirstShadow("First Shadow", Float) = 0.543
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.7454, 0.7454, 0.7454, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.66155, 0.78444, 0.8337, 1)

		_SpecularIntensity("Specular Intensity", Float) = 0
		_SpecularShiness("Specular Shiness", Float) = 1
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 0.9528, 0.71656, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 0.0
		[Linear]_EmissionColor("Emission Color", Vector) = (0.0, 0.0, 0.0, 0)

		_RimMin("Rim Min", Float) = 0.3
		_RimMax("Rim Max", Float) = 0.5
		_RimIntensity("Rim Intensity", Float) = 0.37
		[Linear]_RimColor("Rim Color", Vector) = (1.0, 1.0, 1.0, 1.0)
		_RimThreshold("Rim Threshold", Float) = 0.435
		_RimDistanceMin("Rim Distance Min", Float) = -3.0
		_RimDistanceMax("Rim Distance Max", Float) = 4.0

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.09

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.83683, 0.83683, 0.83683, 1.00)

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
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			// -------------------------------------
			// 自定义宏
			#define SHADOW_SMOOTH_ON
			#define MATCAP_ON
			#define MIX_ALPHA_OFF

			#include "EquipBasePass.cginc"
			ENDCG
		}

		Pass
		{
			Name "Bloom"

			Cull off
			Blend off
			ColorMask A
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "../Pass/BloomPass.cginc"
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
