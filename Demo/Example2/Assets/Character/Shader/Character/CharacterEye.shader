Shader "Example/Character/Eye"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_StencilMaskTex("Stencil Mask Map", 2D) = "white" {}

		_SmoothFactor("Smooth Factor", Float) = 0.079

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_FirstShadow("First Shadow", Float) = 0.52
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.46677, 0.39317, 0.64448, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (1.0, 1.0, 1.0, 1)

		_SpecularIntensity("Specular Intensity", Float) = 0.1
		_SpecularShiness("Specular Shiness", Float) = 22.0
		[Linear]_SpecularColor("Specular Color", Vector) = (0.21404, 0.21404, 0.21404, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 0.0
		[Linear]_EmissionColor("Emission Color", Vector) = (0.0, 0.0, 0.0, 0)

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.15
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.0

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 1.0)

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

			// -------------------------------------
			// 自定义宏
			//#define USE_VERTEX_COLOR
			//#define USE_UV1
			//#define L_PBR_ON
			//#define L_AO_ON
			#define SHADOW_SMOOTH_ON

			#include "CharacterEyePass.cginc"
			ENDCG
		}

		Pass
		{
			Name "StencilMask"

			Cull off
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "../Pass/StencilMaskPass.cginc"
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