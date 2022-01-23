Shader "Example/Character/Face"
{
    Properties
    {
		_BaseTex("Albedo", 2D) = "white" {}
		_MaskTex("Mask(R: 高光范围 G: 自投影区域 B: 高光强度 A: 自发光区域)", 2D) = "white" {}
		_SkinRamp("Skin Ramp", 2D) = "white" {}
		_StencilMaskTex("Stencil Mask Map", 2D) = "white" {}

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1, 1, 1, 1)
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		_SkinRate("Skin Rate", Float) = 0.15
		_SkinIntensity("Skin Intensity", Float) = 1.0
		[Linear]_SkinColor("Skin Color", Vector) = (1.0, 1.0, 1.0, 1)

		_FirstShadow("First Shadow", Float) = 0.45
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.7454, 0.57112, 0.57112, 1)

		_SecondShadow("Second Shadow", Float) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.7454, 0.57113, 0.57113, 1)

		_SpecularIntensity("Specular Intensity", Float) = 0.4
		_SpecularShiness("Specular Shiness", Float) = 30.7
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_EmissionIntensity("Emission Intensity", Float) = 0.0
		[Linear]_EmissionColor("Emission Color", Vector) = (0.0, 0.0, 0.0, 0)
			 
		_RimMin("Rim Min", Float) = 0.69
		_RimMax("Rim Max", Float) = 0.72
		_RimIntensity("Rim Intensity", Float) = 1.37
		[Linear]_RimColor("Rim Color", Vector) = (1.0, 1.0, 1.0, 1.0)
		_RimThreshold("Rim Threshold", Float) = 0.1
		_RimDistanceMin("Rim Distance Min", Float) = -0.5
		_RimDistanceMax("Rim Distance Max", Float) = 20

		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		_BloomFactor("Bloom Factor", Float) = 0.04
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.0

		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (0.9184, 0.70961, 0.6662, 1.0)

		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.19419, 0.06265, 0.06485, 0.29804)

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

			Cull back
			Blend off//SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#define USE_VERTEX_COLOR
			#define USE_SHADOWMAP

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "CharacterPass.cginc"
            ENDCG
        }

		Pass
		{
			Name "Outline"
			Tags{ "LightMode" = "ForwardBase" }

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

			#include "../Pass/OutlinePass.cginc"
			ENDCG
		}

		Pass
		{
			Name "StencilMask"

			ColorMask off
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
