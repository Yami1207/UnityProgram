Shader "Example/Home/SceneObj/Wall"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		[Linear]_Color("Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		[Space(20)]
		_BumpTex("Bump", 2D) = "black" {}
		_BumpScale("Bump Scale", Float) = 0.01

		[Space(20)]
		_AOScale("AO Scale", Float) = 1.0
		_Metallic("Metallic", Float) = 0.378
		_Roughness("Roughness", Float) = 0.048

		[Space(20)]
		_SpecularIntensity("Specular Intensity", Float) = 1.0
		[Linear]_SpecularColor("Specular Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		[Space(20)]
		_CubeMap("Cube Map", CUBE) = "" {}
		_CubemapIntensity("Cubemap Intensity", Float) = 1.0
		[Linear]_CubemapColor("Cubemap Color", Vector) = (1.0, 1.0, 1.0, 1.0)

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

			#define _NORMAL_MAP_ON		1
			#define _USE_PRB_LIGHTING	1

			#include "SceneObj.cginc"
			ENDCG
		}
	}
}
