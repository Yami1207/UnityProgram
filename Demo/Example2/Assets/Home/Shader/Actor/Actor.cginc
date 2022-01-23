#ifndef __ACTOR_CGINC__
#define __ACTOR_CGINC__

#include "../Lib/Core.cginc"

//////////////////////////////////////////////
// 顶点输入数据
struct Attributes
{
	float4 positionOS	: POSITION;
	float2 uv0			: TEXCOORD0;
	float2 uv1			: TEXCOORD1;
	float3 normalOS		: NORMAL;
};

//////////////////////////////////////////////
// 片元输入数据
struct Varyings
{
	float4 positionCS		: SV_POSITION;
	float4 uv				: TEXCOORD0;
	float3 positionWS		: TEXCOORD1;
	float3 normalWS			: TEXCOORD2;
	float3 vertexLighting	: TEXCOORD3;
};

//////////////////////////////////////////////
// 材质输入
uniform half4 _AlbedoColor;

uniform half3 _SkinColor;
uniform half _SkinIntensity;
uniform half _SkinRate;

uniform half3 _NoShadowColor;
uniform half _SmoothFactor;

uniform half _FirstShadow;
uniform half3 _FirstShadowColor;

uniform half _SecondShadow;
uniform half3 _SecondShadowColor;

uniform half _SpecularIntensity;
uniform half _SpecularShiness;
uniform half3 _SpecularColor;

uniform half _RimMin;
uniform half _RimMax;
uniform half _RimIntensity;
uniform half3 _RimColor;
uniform half _RimThreshold;
uniform half _RimDistanceMin;
uniform half _RimDistanceMax;

uniform half _EmissionIntensity;
uniform half3 _EmissionColor;

uniform half _EffectRimFading;
uniform half _EffectRimTransparency;
uniform half3 _EffectRimColor;

//////////////////////////////////////////////
// 贴图
uniform sampler2D _BaseTex;
uniform float4 _BaseTex_ST;

uniform sampler2D _FaceTex;

uniform sampler2D _MaskTex;
uniform float4 _MaskTex_ST;

uniform sampler2D _SkinRamp;

//////////////////////////////////////////////
// 功能函数
#include "../Lib/Functions.cginc"

SurfaceData GetSurfaceData(float4 uv)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(uv.xy, _BaseTex)));
	half4 faceColor = G2L(tex2D(_FaceTex, uv.zw));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(uv.xy, _MaskTex));

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
	outSurfaceData.albedo = lerp(baseColor.rgb, faceColor.rgb, faceColor.a) * _AlbedoColor.rgb;
	outSurfaceData.alpha = baseColor.a * _AlbedoColor.a;

	// PBR
	//outSurfaceData.roughness = _Roughness;
	//outSurfaceData.metallic = _Metallic;
	//outSurfaceData.occlusion = _AOScale;

	outSurfaceData.lightMask = maskColor.y;
	outSurfaceData.noShadowColor = _NoShadowColor * _G_CharacterNoShadowColor;
	outSurfaceData.shadowSmooth = _SmoothFactor;

	// 第一层阴影颜色与阀值
	outSurfaceData.firstShadowColor = _FirstShadowColor * _G_CharacterOneShadowColor;
	outSurfaceData.firstShadowThreshold = _FirstShadow;

	// 第二层阴影颜色与阀值
	outSurfaceData.secondShadowColor = _SecondShadowColor * _G_CharacterTwoShadowColor;
	outSurfaceData.secondShadowThreshold = _SecondShadow;

	// 高光
	outSurfaceData.specMask = maskColor.r;
	outSurfaceData.specGloss = _SpecularShiness;
	outSurfaceData.specular = maskColor.b * _SpecularIntensity * _SpecularColor;

	outSurfaceData.skinRimColor = _RimColor;

	// 自发光
	outSurfaceData.emissionFactor = maskColor.a;
	outSurfaceData.emission = outSurfaceData.albedo * _EmissionIntensity * _EmissionColor;

	// 边缘光
	outSurfaceData.rimFading = _EffectRimFading;
	outSurfaceData.rimColor = _EffectRimColor * _EffectRimTransparency;

	return outSurfaceData;
}

InputData GetInputData(Varyings vertexOutput, SurfaceData surfaceData)
{
	InputData outInputData = GetDefaultInputData();
	outInputData.positionWS = vertexOutput.positionWS;
	outInputData.normalWS = normalize(vertexOutput.normalWS);
	outInputData.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - outInputData.positionWS);
	return outInputData;
}

EnvData GetEnvData(Varyings vertexOutput)
{
	EnvData outEnvData = GetDefaultEnvData();
	outEnvData.specularColor = _G_CharSpecularColor;
	outEnvData.shadowIntensity = _G_CharacterShadowIntensity;
	return outEnvData;
}

// 根据NoL_01返回皮肤颜色
half3 GetSkinColor(SurfaceData surfaceData, BxDFContext bxdfContext)
{
	half2 uv = half2(bxdfContext.NoL_01, 0.5);
	half3 skinColor = G2L(tex2D(_SkinRamp, uv)).rgb;
	skinColor *= surfaceData.albedo * _SkinIntensity * _SkinColor;
	return lerp(surfaceData.albedo, skinColor, _SkinRate);
}

//////////////////////////////////////////////
// 顶点函数
Varyings vert(Attributes input)
{
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);

	Varyings output = (Varyings)0;
	output.positionCS = vertexInput.positionCS;
	output.positionWS = vertexInput.positionWS;
	output.uv = float4(input.uv0, input.uv1);
	output.normalWS = UnityObjectToWorldNormal(input.normalOS);
	output.vertexLighting = VertexLighting(vertexInput.positionWS, output.normalWS);
	return output;
}

//////////////////////////////////////////////
// 片元函数
half4 frag(Varyings input) : SV_Target
{
	half3 lightDir = normalize(_G_CharacterLightDir);
	SurfaceData surfaceData = GetSurfaceData(input.uv);
	InputData inputData = GetInputData(input, surfaceData);
	BxDFContext bxdfContext = GetBxDFContext(inputData, lightDir);
	EnvData envData = GetEnvData(input);

	half3 skinColor = GetSkinColor(surfaceData, bxdfContext);
	half3 color = Actor_LightingDiffuse(skinColor, surfaceData, bxdfContext, envData);
	color += Actor_LightingSpecular(skinColor, surfaceData, bxdfContext, envData);

	color += CalcSkinRimColor(inputData, surfaceData, bxdfContext, half2(_RimMin, _RimMax), half2(_RimDistanceMin, _RimDistanceMax), _RimIntensity, _RimThreshold);

	color *= _G_CharacterLightColor;
	color += color * input.vertexLighting;

	// 自发光
	color = MixEmission(color, surfaceData);

	// 边缘光
	color = MixRimLight(color, surfaceData, bxdfContext);

	// 环境光
	color = MixAmbient(color);

	// 与Bloom颜色混合
	color = MixBloomColor(color);

	// 雾
	color = MixFog(color, inputData);

	// Bloom系数
	half alpha = GetBloomFactor(surfaceData.alpha, surfaceData.emissionFactor);

	return L2G(half4(color, alpha));
}

#endif
