#ifndef __INPUT_CGINC__
#define __INPUT_CGINC__

//////////////////////////////////////////////
// 全局变量
uniform float3 _G_LightDir;
uniform half3 _G_LightColor;
uniform half3 _G_DynamicAmbientColor;
uniform half3 _G_SpecularColor;

uniform float3 _G_CharacterLightDir;
uniform half3 _G_TintColor;
uniform half3 _G_CharacterAmbientColor;
uniform half3 _G_CharacterLightColor;
uniform half3 _G_CharSpecularColor;

uniform half _G_CharacterShadowIntensity;
uniform half3 _G_CharacterNoShadowColor;
uniform half3 _G_CharacterOneShadowColor;
uniform half3 _G_CharacterTwoShadowColor;

uniform half _G_EnableDistanceRim;
uniform float3 _G_RimLightDir;
uniform half3 _G_CharacterRimColor;

uniform half _G_PostBloom;
uniform half4 _G_SceneDarkColor;
uniform float _G_SceneGray;

uniform sampler2D _G_GroundReflectionTex;

// 点光源颜色
uniform float4 _G_SphereLightCharacterA[3];

// 点光源位置
uniform float4 _G_SphereLightCharacterB[3];

//////////////////////////////////////////////
// 功能结构体与函数
struct VertexPositionInputs
{
	float3 positionWS; // World space position
	float3 positionVS; // View space position
	float4 positionCS; // Homogeneous clip space position
};

VertexPositionInputs GetVertexPositionInputs(float4 positionOS)
{
	VertexPositionInputs input;
	input.positionWS = mul(unity_ObjectToWorld, positionOS).xyz;
	input.positionVS = UnityObjectToViewPos(positionOS);
	input.positionCS = UnityObjectToClipPos(positionOS);
	return input;
}

struct VertexNormalInputs
{
	float3 tangentWS;
	float3 bitangentWS;
	float3 normalWS;
};

VertexNormalInputs GetVertexNormalInputs(float3 normalOS, float4 tangentOS)
{
	VertexNormalInputs tbn;
	tbn.normalWS = UnityObjectToWorldNormal(normalOS);
	tbn.tangentWS = UnityObjectToWorldDir(tangentOS.xyz);

	half sign = tangentOS.w * unity_WorldTransformParams.w;
	tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;

	return tbn;
}

//////////////////////////////////////////////
// 片元顶点参数
struct InputData
{
	float3  positionWS;
	float4	positionSS;
	half3   normalWS;
	half3   viewDirectionWS;
};

InputData GetDefaultInputData()
{
	InputData data = (InputData)0;
	return data;
}

//////////////////////////////////////////////
// 材质表面输入参数
struct SurfaceData
{
	half3 albedo;
	half alpha;
	half3 normalTS;

	// 金属度
	half metallic;

	// 粗糙度
	half roughness;

	// 遮罩
	half occlusion;

	// 亮部区域
	half lightMask;

	// 亮部颜色
	half3 noShadowColor;

	// 阴影平滑过渡
	half shadowSmooth;

	// 第一层阴影（暗部）
	half3 firstShadowColor;
	half firstShadowThreshold;

	// 第二层阴影（凹部）
	half3 secondShadowColor;
	half secondShadowThreshold;

	// 高光
	half specMask;
	half specGloss;
	half3 specular;

	half3 skinRimColor;

	// 自发光
	half3 emission;
	half emissionFactor;

	half rimFading;
	half3 rimColor;
};

SurfaceData GetDefaultSurfaceData()
{
	SurfaceData data = (SurfaceData)0;
	return data;
}

//////////////////////////////////////////////
// 环境参数
struct EnvData
{
	half3 ambientColor;
	half3 lightColor;

	half3 envColor;
	half3 specularColor;

	half shadowIntensity;
};

EnvData GetDefaultEnvData()
{
	EnvData data = (EnvData)0;
	return data;
}

#endif
