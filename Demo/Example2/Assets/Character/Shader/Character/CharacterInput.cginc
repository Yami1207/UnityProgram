#ifndef __CHARACTER_INPUT_CGINC__
#define __CHARACTER_INPUT_CGINC__

#include "../Lib/Core.cginc"

struct Attributes
{
	float4 positionOS	: POSITION;
	float2 uv			: TEXCOORD0;
	float3 normalOS		: NORMAL;
	float4 tangentOS    : TANGENT;
#if defined(USE_VERTEX_COLOR)
	float4 color		: COLOR0;
#endif
};

struct Varyings
{
	float4 positionCS	: SV_POSITION;
	float2 uv           : TEXCOORD0;
	float4 positionWSAndFogCoord	: TEXCOORD1;	// xyz: positionWS, w: FogCoord
	float3 normalWS		: TEXCOORD2;
#if defined(USE_NORMAL_MAP)
	float3 tangentWS	: TEXCOORD3;
	float3 bitangentWS	: TEXCOORD4;
#endif

	float3 vertexLighting	: TEXCOORD5;
#if defined(USE_VERTEX_COLOR)
	float4 color		: TEXCOORD6;
#endif

#if defined(USE_SHADOWMAP)
	float4 shadowCoord	: TEXCOORD7;
#endif
};

/// <summary>
/// 材质变量
/// </summary>
uniform half4 _AlbedoColor;
uniform half4 _NoShadowColor;

uniform half _BumpScale;

uniform half _SmoothFactor;

uniform half _SkinRate;
uniform half _SkinIntensity;
uniform half4 _SkinColor;

uniform half _FirstShadow;
uniform half4 _FirstShadowColor;

uniform half _SecondShadow;
uniform half4 _SecondShadowColor;

uniform half _SpecularShadowIntensity;
uniform half _SpecularIntensity;
uniform half _SpecularShiness;
uniform half4 _SpecularColor;

uniform half _RimMin;
uniform half _RimMax;
uniform half _RimIntensity;
uniform half4 _RimColor;
uniform half _RimThreshold;
uniform half _RimDistanceMin;
uniform half _RimDistanceMax;

uniform half _EffectRimFading;
uniform half _EffectRimTransparency;
uniform half4 _EffectRimColor;

uniform half _EmissionIntensity;
uniform half4 _EmissionColor;

uniform half _BloomFactor;
uniform half _EmissionBloomFactor;

uniform half _BloomModIntensity;
uniform half4 _BloomModColor;

/// <summary>
/// 贴图
/// </summary>
uniform sampler2D _BaseTex;
uniform half4 _BaseTex_ST;

uniform sampler2D _MaskTex;
uniform half4 _MaskTex_ST;

uniform sampler2D _NormalTex;
uniform half4 _NormalTex_ST;

uniform sampler2D _SkinRamp;

#include "../Lib/Functions.cginc"

Varyings vert(Attributes input)
{
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

	Varyings output;
	output.positionCS = vertexInput.positionCS;
	output.uv = input.uv;
	output.positionWSAndFogCoord = float4(vertexInput.positionWS, fogFactor);

	// 切线空间
	output.normalWS = normalInput.normalWS;

#if defined(USE_NORMAL_MAP)
	output.tangentWS = normalInput.tangentWS;
	output.bitangentWS = normalInput.bitangentWS;
#endif

	// 顶点光照颜色
	output.vertexLighting = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

#if defined(USE_VERTEX_COLOR)
	output.color = input.color;
#endif

	// 计算阴影坐标
#if defined(USE_SHADOWMAP)
	output.shadowCoord = GetShadowCoord(vertexInput.positionWS);
#endif

	return output;
}

#endif
