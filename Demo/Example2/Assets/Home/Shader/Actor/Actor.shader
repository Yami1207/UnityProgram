Shader "Example/Home/Actor"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		_FaceTex("Face", 2D) = "black" {}
		_MaskTex("Mask(R:高光范围 G:亮部 B:高光强度 A:自发光)", 2D) = "black" {}

		[Linear]_AlbedoColor("Albedo Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		[Space(20)]
		_SkinRamp("皮肤明暗梯度图", 2D) = "white" {}
		[Linear]_SkinColor("皮肤颜色", Vector) = (1, 1, 1, 1)
		_SkinIntensity("皮肤颜色强度", Range(0, 2)) = 1.0
		_SkinRate("皮肤颜色权重", Range(0, 1)) = 0.3

		[Space(20)]
		[Linear]_NoShadowColor("No Shadow Color", Vector) = (1, 1, 1, 1)

		[Toggle(_SHADOW_SMOOTH_ON)] _SHADOW_SMOOTH_ON("开启阴影平滑", Float) = 0
		_SmoothFactor("阴影平滑", Range(0.0001, 0.1)) = 0.0001

		_FirstShadow("First Shadow Threshold", Range(0.0, 1.0)) = 0.414
		[Linear]_FirstShadowColor("First Shadow Color", Vector) = (0.3564, 0.31399, 0.28315, 1)

		_SecondShadow("Second Shadow Threshold", Range(0.0, 1.0)) = 0.51
		[Linear]_SecondShadowColor("Second Shadow Color", Vector) = (0.35762, 0.31337, 0.28166, 1)

		[Space(20)]
		_SpecularIntensity("Specular Intensity", Float) = 0.36
		_SpecularShiness("Specular Shiness", Float) = 12.0
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		[Space(20)]
		_RimMin("Rim Min", Float) = 0.65
		_RimMax("Rim Max", Float) = 0.67
		_RimIntensity("Rim Intensity", Float) = 0.15
		[Linear]_RimColor("Rim Color", Vector) = (1.0, 1.0, 1.0, 1.0)
		_RimThreshold("Rim Threshold", Float) = 0.2
		_RimDistanceMin("Rim Distance Min", Float) = 20.0
		_RimDistanceMax("Rim Distance Max", Float) = 19.4

		[Space(20)]
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.0
		_EmissionIntensity("Emission Intensity", Float) = 0.0
		[Linear]_EmissionColor("Emission Color", Vector) = (0.0, 0.0, 0.0, 1.00)

		[Space(20)]
		_EffectRimFading("Effect Rim Fading", Float) = 0.0
		_EffectRimTransparency("Effect Rim Transparency", Float) = 0.0
		[Linear]_EffectRimColor("Effect Rim Color", Vector) = (0.0, 0.0, 0.0, 0.0)

		[Space(20)]
		_BloomFactor("Bloom Factor", Float) = 0.0
		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 0.0)
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+200" }
		LOD 100
		Blend off
		Cull back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature __ _SHADOW_SMOOTH_ON

			#include "Actor.cginc"

			ENDCG
		}
	}
}
