Shader "Example/Home/SceneObj/Ground"
{
	Properties
	{
		_BaseTex("Albedo", 2D) = "white" {}
		[Linear]_Color("Color", Vector) = (1.0, 1.0, 1.0, 1.0)

		_ReflectIntensity("Reflect Intensity", Range(0.0, 1.0)) = 0.05

		[Space(20)]
		_BloomFactor("Bloom Factor", Float) = 0.0
		_BloomModIntensity("Bloom Mod Intensity", Float) = 1.0
		[Linear]_BloomModColor("Bloom Mod Color", Vector) = (1.0, 1.0, 1.0, 0.0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Blend off
		Cull back

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#define _USE_GROUND_REFLECTION	1

			#include "SceneObj.cginc"
			ENDCG
		}
	}
}
