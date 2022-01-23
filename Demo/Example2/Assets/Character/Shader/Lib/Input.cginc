#ifndef __INPUT_CGINC__
#define __INPUT_CGINC__

//////////////////////////////////////////////
// ȫ�ֱ���

// ���Դ��ɫ
uniform float4 _XSphereLightCharacterA[3];

// ���Դ�����뷶Χ
uniform float4 _XSphereLightCharacterB[3];

uniform half3 _GlobalRimLightDir;
uniform half _GlobalEnableDistanceRim;

uniform half _XPostBloom;
uniform half3 _GlobalTint;

uniform float4x4 _XShadowWorldToProj;
uniform half3 _XWorldSpaceShadowLightDir;
uniform half _XShadowNormalBias;
uniform half _XShadowOffset;
uniform sampler2D _XShadowTexture;

uniform half3 _XGlobalCharSpecularColor;
uniform half3 _XGlobalCharacterNoShadowColor;
uniform half3 _XGlobalCharacterOneShadowColor;
uniform half3 _XGlobalCharacterTwoShadowColor;
uniform half3 _XGlobalCharacterLightColor;
uniform half3 _XGlobalCharacterLightDir;
uniform half3 _XGlobalCharacterAmbientColor;

uniform half3 _XGlobalCharacterSkinNoShadowColor;
uniform half3 _XGlobalCharacterSkinOneShadowColor;
uniform half3 _XGlobalCharacterSkinTwoShadowColor;
uniform half3 _XGlobalCharacterSkinRimColor;

//////////////////////////////////////////////
// ƬԪ�������
struct InputData
{
	float3  positionWS;
	half3   normalWS;
	half3   viewDirectionWS;

	half3   vertexLighting;

	half	isShadow;
	//float4  shadowCoord;

	half    fogCoord;
};

InputData GetDefaultInputData()
{
	InputData data = (InputData)0;
	data.isShadow = 0.0;
	return data;
}

//////////////////////////////////////////////
// ���ʱ����������
struct SurfaceData
{
	half3 albedo;
	half  alpha;
	half3 normalTS;

	half pbrRate;
	half roughness;
	half metallic;
	half occlusion;

	half3 diffuse;

	half shadowMask;
	half shadowSmooth;

	half4 firstShadow;	// xyz: ��Ӱ��ɫ w:��ֵ
	half4 secondShadow;	// xyz: ��Ӱ��ɫ w:��ֵ

	half specMask;
	half specGloss;
	half3 specular;

	half3 emission;
	half3 emissionFactor;

	half rimFading;
	half3 rimColor;

	half3 skinRimColor;
};

SurfaceData GetDefaultSurfaceData()
{
	SurfaceData data = (SurfaceData)0;
	return data;
}

struct EnvData
{
	half3 envColor;

	half directLightIntensity;
	half3 directLightColor;

	half indirectLightIntensity;
	half3 indirectLightColor;
};

EnvData GetDefaultEnvData()
{
	EnvData data = (EnvData)0;
	return data;
}

#endif
