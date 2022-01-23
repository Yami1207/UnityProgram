#ifndef __EQUIP_BASE_PASS_CGINC__
#define __EQUIP_BASE_PASS_CGINC__

#include "../Lib/Core.cginc"

//////////////////////////////////////////////
// �ֲ��궨��
/*
USE_VERTEX_COLOR	// ʹ�ö�����ɫ
USE_UV1				// ʹ��UV1
L_PBR_ON			// PBR
L_AO_ON				// AO����
SHADOW_SMOOTH_ON	// ��Ӱƽ������
MATCAP_ON			// ʹ��MatCap
MIX_ALPHA_OFF		// �ر�alpha��bloom���
*/

//////////////////////////////////////////////
// ���ʲ���
uniform half _AOScale;
uniform half _BumpScale;
uniform half _MetallicMapScale;
uniform half _RoughnessMapScale;

uniform half _MatCapYScale;
uniform half _SmoothFactor;

uniform half4 _AlbedoColor;
uniform half4 _NoShadowColor;

uniform half4 _DirectLightColor;

uniform half _IndirectLightIntensity;
uniform half4 _IndirectLightColor;

uniform half _PBRRate;
uniform half _PBRSpecularIntensity;
uniform half4 _PBRSpecularColor;

uniform half _CubemapIntensity;
uniform half4 _CubemapColor;

uniform half _FirstShadow;
uniform half4 _FirstShadowColor;

uniform half _SecondShadow;
uniform half4 _SecondShadowColor;

uniform half _SpecularIntensity;
uniform half _SpecularShiness;
uniform half4 _SpecularColor;

uniform half _EmissionIntensity;
uniform half4 _EmissionColor;

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

uniform half _BloomFactor;
uniform half _EmissionBloomFactor;

uniform half _BloomModIntensity;
uniform half4 _BloomModColor;

//////////////////////////////////////////////
// ��ͼ
uniform sampler2D _BaseTex;
uniform half4 _BaseTex_ST;

uniform sampler2D _PBRMask;
uniform half4 _PBRMask_ST;

uniform sampler2D _DetailMap;
uniform half4 _DetailMap_ST;

uniform sampler2D _MaskTex;
uniform half4 _MaskTex_ST;

uniform sampler2D _NormalTex;
uniform half4 _NormalTex_ST;

uniform sampler2D _MatCapTex;
uniform half4 _MatCapTex_ST;

UNITY_DECLARE_TEXCUBE(_CubeMap);
half4 _CubeMap_HDR;
//uniform samplerCUBE _CubeMap;

//////////////////////////////////////////////
// ����ṹ��
struct Attributes
{
	float4 positionOS	: POSITION;
	float2 uv			: TEXCOORD0;
#if defined(USE_UV1)
	float2 uv1			: TEXCOORD1;
#endif
	float3 normalOS		: NORMAL;
	float4 tangentOS    : TANGENT;
#if defined(USE_VERTEX_COLOR)
	float4 color		: COLOR0;
#endif
};

//////////////////////////////////////////////
// ƬԪ�ṹ��
struct Varyings
{
	float4 positionCS	: SV_POSITION;
	float4 uv           : TEXCOORD0;
	float4 positionWSAndFogCoord	: TEXCOORD1;	// xyz: positionWS, w: FogCoord
	float3 normalWS		: TEXCOORD2;
	float3 tangentWS	: TEXCOORD3;
	float3 bitangentWS	: TEXCOORD4;
	float3 vertexLighting	: TEXCOORD5;
#if defined(USE_VERTEX_COLOR)
	float4 color		: TEXCOORD6;
#endif
	float4 shadowCoord	: TEXCOORD7;
};

//////////////////////////////////////////////
// ���ܺ���
#include "../Lib/Functions.cginc"

SurfaceData GetSurfaceData(Varyings input)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(input.uv.xy, _BaseTex)));
	half4 detailColor = G2L(tex2D(_DetailMap, TRANSFORM_TEX(input.uv.zw, _DetailMap)));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(input.uv.xy, _MaskTex));		// R:�߹ⷶΧ G:��ͶӰ���� B:�߹� A:�Է���
	half3 normalColor = tex2D(_NormalTex, TRANSFORM_TEX(input.uv.xy, _NormalTex)).xyz;
	half4 pbrMaskColor = tex2D(_PBRMask, TRANSFORM_TEX(input.uv.xy, _PBRMask));		// _PBRMask(R:�ֲڶ� G:������ B: A:PBR����)

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
#if defined(USE_UV1)
	outSurfaceData.albedo = _AlbedoColor.rgb * lerp(baseColor.rgb, detailColor.rgb, detailColor.a);
#else
	outSurfaceData.albedo = _AlbedoColor.rgb * baseColor.rgb;
#endif
	outSurfaceData.alpha = GetSurfaceAlpha(baseColor.a);

	// ����
	outSurfaceData.normalTS = 2.0 * normalColor - 1.0;
	outSurfaceData.normalTS.xy *= _BumpScale;

	// PBR
	outSurfaceData.pbrRate = pbrMaskColor.a * _PBRRate;
	outSurfaceData.roughness = pbrMaskColor.r * _RoughnessMapScale;
	outSurfaceData.metallic = pbrMaskColor.g * _MetallicMapScale;

	outSurfaceData.occlusion = 1.0 + _AOScale * (pbrMaskColor.b - 1.0);

	outSurfaceData.diffuse = _NoShadowColor.rgb * _XGlobalCharacterNoShadowColor.rgb;

	// ��Ӱ
#if defined(USE_VERTEX_COLOR)
	outSurfaceData.shadowMask = 2.0 * input.color.y + maskColor.y;
	outSurfaceData.shadowMask = saturate(outSurfaceData.shadowMask - 1.0);
#else
	outSurfaceData.shadowMask = maskColor.g;
#endif
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

#if defined(USE_VERTEX_COLOR)
	outSurfaceData.skinRimColor = _RimColor.rgb * input.color.w;
#else
	outSurfaceData.skinRimColor = _RimColor.rgb;
#endif

	return outSurfaceData;
}

InputData GetInputData(Varyings vertexOutput, SurfaceData surfaceData)
{
	InputData outInputData = GetDefaultInputData();
	outInputData.positionWS = vertexOutput.positionWSAndFogCoord.xyz;
	outInputData.fogCoord = vertexOutput.positionWSAndFogCoord.w;

	// ����
	half3 normalWS = mul(surfaceData.normalTS, half3x3(vertexOutput.tangentWS, vertexOutput.bitangentWS, vertexOutput.normalWS));
	normalWS = SafeNormalize(normalWS);
	outInputData.normalWS = normalWS;

	outInputData.isShadow = SampleShadowMap(vertexOutput.shadowCoord, normalWS);

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
#if defined(USE_UV1)
	output.uv = float4(input.uv, input.uv1);
#else
	output.uv = float4(input.uv, 0.0, 0.0);
#endif
	output.positionWSAndFogCoord = float4(vertexInput.positionWS, fogFactor);

	// ���߿ռ�
	output.normalWS = normalInput.normalWS;
	output.tangentWS = normalInput.tangentWS;
	output.bitangentWS = normalInput.bitangentWS;

	// ���������ɫ
	output.vertexLighting = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

#if defined(USE_VERTEX_COLOR)
	output.color = input.color;
#endif

	output.shadowCoord = GetShadowCoord(vertexInput.positionWS);

	return output;
}

//////////////////////////////////////////////
// ƬԪ����
half4 frag(Varyings input) : SV_Target
{
	half3 lightDir = SafeNormalize(_XGlobalCharacterLightDir);

	SurfaceData surfaceData = GetSurfaceData(input);
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

	color += CalcSkinRimColor(inputData, surfaceData, bxdfContext, half2(_RimMin, _RimMax), half2(_RimDistanceMin, _RimDistanceMax), _RimIntensity, _RimThreshold);
	
	color *= _XGlobalCharacterLightColor.rgb;
	color += color * input.vertexLighting;
	
#if defined(MATCAP_ON)
	color += CalcMatCap(inputData, surfaceData, _MatCapYScale, _MatCapTex);
#endif

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
