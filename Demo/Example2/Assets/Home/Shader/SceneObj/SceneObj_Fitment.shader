Shader "Example/Home/SceneObj/Fitment"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		[Linear]_Color("Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_MaskTex("Mask(A:自发光)", 2D) = "black" {}

		[Space(20)]
		[Toggle(_NORMAL_MAP_ON)] _NORMAL_MAP_ON("使用法线贴图", Float) = 0
		_BumpTex("Bump", 2D) = "black" {}
		_BumpScale("Bump Scale", Float) = 1.0

		[Space(20)]
		[Toggle(_EMISSION_ON)] _EMISSION_ON("开启自发光", Float) = 0
		_EmissionBloomFactor("Emission Bloom Factor", Float) = 0.0
		_EmissionIntensity("Emission Intensity", Float) = 1.9
		[Linear]_EmissionColor("Emission Color", Vector) = (1.0, 1.0, 1.0, 1.00)

		[Space(20)]
		_BloomFactor("Bloom Factor", Float) = 0.0
		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 0.0)
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100
		Blend off
		Cull back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature __ _NORMAL_MAP_ON
			#pragma shader_feature __ _EMISSION_ON

			#include "SceneObj.cginc"
			ENDCG
		}
	}
}
