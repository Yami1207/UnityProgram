#ifndef __WEAPON_PASS_CGINC__
#define __WEAPON_PASS_CGINC__

#include "../Lib/Core.cginc"

//////////////////////////////////////////////
// �ֲ��궨��
/*
// PBR
L_PBR_ON

// ��Ӱƽ������
SHADOW_SMOOTH_ON
*/

//////////////////////////////////////////////
// ���ʲ���
uniform half _BumpScale;

uniform half4 _AlbedoColor;
uniform half4 _NoShadowColor;

uniform half _FirstShadow;
uniform half4 _FirstShadowColor;

uniform half _SecondShadow;
uniform half4 _SecondShadowColor;

uniform half _SpecularIntensity;
uniform half _SpecularShiness;
uniform half4 _SpecularColor;

uniform half _EmissionIntensity;
uniform half4 _EmissionColor;

uniform half _EffectRimFading;
uniform half _EffectRimTransparency;
uniform half4 _EffectRimColor;

uniform half _Roughness;
uniform half _Metallic;

uniform half _PBRRate;
uniform half _SmoothFactor;

uniform half4 _DirectLightColor;

uniform half _IndirectLightIntensity;
uniform half4 _IndirectLightColor;

uniform half _PBRSpecularIntensity;
uniform half4 _PBRSpecularColor;

uniform half _CubemapIntensity;
uniform half4 _CubemapColor;

uniform half _BloomFactor;
uniform half _EmissionBloomFactor;

uniform half _BloomModIntensity;
uniform half4 _BloomModColor;

//////////////////////////////////////////////
// ��ͼ
uniform sampler2D _BaseTex;
uniform half4 _BaseTex_ST;

uniform sampler2D _MaskTex;
uniform half4 _MaskTex_ST;

uniform sampler2D _NormalTex;
uniform half4 _NormalTex_ST;

UNITY_DECLARE_TEXCUBE(_CubeMap);
half4 _CubeMap_HDR;
//uniform samplerCUBE _CubeMap;

//////////////////////////////////////////////
// ����ṹ��
struct Attributes
{
	float4 positionOS	: POSITION;
	float2 uv			: TEXCOORD0;
	float3 normalOS		: NORMAL;
	float4 tangentOS    : TANGENT;
};

//////////////////////////////////////////////
// ƬԪ�ṹ��
struct Varyings
{
	float4 positionCS				: SV_POSITION;
	float2 uv						: TEXCOORD0;
	float4 positionWSAndFogCoord	: TEXCOORD1;	// xyz: positionWS, w: FogCoord
	float3 normalWS					: TEXCOORD2;
	float3 tangentWS				: TEXCOORD3;
	float3 bitangentWS				: TEXCOORD4;
	float3 vertexLighting			: TEXCOORD5;
};

//////////////////////////////////////////////
// ���ܺ���
#include "../Lib/Functions.cginc"

SurfaceData GetSurfaceData(float2 uv)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(uv, _BaseTex)));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(uv, _MaskTex));	// R:�߹ⷶΧ G:��ͶӰ���� B:�߹� A:�Է���
	half3 normalColor = tex2D(_NormalTex, TRANSFORM_TEX(uv, _NormalTex)).xyz;// UnpackNormal()).xyz;

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
	outSurfaceData.albedo = baseColor.rgb * _AlbedoColor.rgb;
	outSurfaceData.alpha = GetSurfaceAlpha(baseColor.a);

	// ����
	outSurfaceData.normalTS = 2.0 * normalColor - 1.0;
	outSurfaceData.normalTS.xy *= _BumpScale;

	// PBR
	outSurfaceData.pbrRate = _PBRRate;
	outSurfaceData.roughness = _Roughness;
	outSurfaceData.metallic = _Metallic;

	outSurfaceData.diffuse = _NoShadowColor.rgb * _XGlobalCharacterNoShadowColor.rgb;

	// ��Ӱ
	outSurfaceData.shadowMask = maskColor.g;
	outSurfaceData.shadowSmooth = _SmoothFactor;
	outSurfaceData.firstShadow = half4(_FirstShadowColor.rgb * _XGlobalCharacterOneShadowColor.rgb, _FirstShadow);
	outSurfaceData.secondShadow = half4(_SecondShadowColor.rgb * _XGlobalCharacterTwoShadowColor.rgb, _SecondShadow);

	// �߹�
	outSurfaceData.specMask = maskColor.r;
	outSurfaceData.specGloss = _SpecularShiness;
	outSurfaceData.specular = maskColor.b * _SpecularIntensity * _SpecularColor;

	// �Է���
	outSurfaceData.emissionFactor = maskColor.a;
	outSurfaceData.emission = outSurfaceData.albedo * _EmissionIntensity * _EmissionColor.rgb;

	// ��Ե��
	outSurfaceData.rimFading = _EffectRimFading;
	outSurfaceData.rimColor = _EffectRimColor.rgb * _EffectRimTransparency;

	return outSurfaceData;
}

InputData GetInputData(Varyings vertexOutput, SurfaceData surfaceData)
{
	InputData outInputData = GetDefaultInputData();
	outInputData.positionWS = vertexOutput.positionWSAndFogCoord.xyz;
	outInputData.fogCoord = vertexOutput.positionWSAndFogCoord.w;
	outInputData.isShadow = 0.0;

	// 
	half3 normalWS = mul(surfaceData.normalTS, half3x3(vertexOutput.tangentWS, vertexOutput.bitangentWS, vertexOutput.normalWS));
	outInputData.normalWS = SafeNormalize(normalWS);

	outInputData.viewDirectionWS = SafeNormalize(_WorldSpaceCameraPos.xyz - outInputData.positionWS);
	outInputData.vertexLighting = vertexOutput.vertexLighting;

	return outInputData;
}

EnvData GetEnvData(Varyings vertexOutput, InputData inputData, BRDFData brdfData, BxDFContext bxdfContext)
{
	EnvData outEnvData = GetDefaultEnvData();
	outEnvData.envColor = 6.0 * _CubemapIntensity * _CubemapColor.rgb;

	outEnvData.directLightIntensity = _PBRSpecularIntensity;
	outEnvData.directLightColor = _DirectLightColor.rgb;

	outEnvData.indirectLightIntensity = _IndirectLightIntensity;
	outEnvData.indirectLightColor = _IndirectLightColor.rgb;

	return outEnvData;
}

//////////////////////////////////////////////
// ���㺯��
Varyings vert(Attributes input)
{
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

	Varyings output;
	output.positionCS = vertexInput.positionCS;
	output.uv = input.uv;
	output.positionWSAndFogCoord = float4(vertexInput.positionWS, fogFactor);

	// ���߿ռ�
	output.normalWS = normalInput.normalWS;
	output.tangentWS = normalInput.tangentWS;
	output.bitangentWS = normalInput.bitangentWS;

	// ���������ɫ
	output.vertexLighting = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

	return output;
}

//////////////////////////////////////////////
// ƬԪ����
half4 frag(Varyings input) : SV_Target
{
	half3 lightDir = SafeNormalize(_XGlobalCharacterLightDir);

	SurfaceData surfaceData = GetSurfaceData(input.uv);
	InputData inputData = GetInputData(input, surfaceData);
	BxDFContext bxdfContext = GetBxDFContext(inputData, lightDir);
	BRDFData brdfData = GetBRDFData(surfaceData);
	EnvData envData = GetEnvData(input, inputData, brdfData, bxdfContext);

	// ��ʼ��
	brdfData.specularColor *= _PBRSpecularColor.rgb;

#if defined(L_PBR_ON)
	half3 lightColor = LightingPhysicallyBased(surfaceData, brdfData, bxdfContext, envData, UNITY_PASS_TEXCUBE(_CubeMap), _CubeMap_HDR);
	surfaceData.albedo = lerp(surfaceData.albedo, lightColor, surfaceData.pbrRate);
#endif

	// ������
	half3 color = LightingDiffuse(inputData, surfaceData, bxdfContext);

	// �߹�
	color += LightingSpecular(surfaceData, bxdfContext);

	color *= _XGlobalCharacterLightColor.rgb;
	color += color * input.vertexLighting;

	// �Է���
	color = MixEmission(color, surfaceData);

	// ��Ե��
	color = MixRimLight(color, surfaceData, bxdfContext);

	// ������
	color = MixAmbient(color);

	// Bloom
	color = MixBloomColor(color);

	// ��
	color = MixFog(color, inputData);

	// ͸����
	half alpha = MixAlpha(surfaceData);

	return FinalColor(color, alpha);
}

#endif
