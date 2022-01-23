#ifndef __SCEN_OBJ_CGINC__
#define __SCEN_OBJ_CGINC__

#include "../Lib/Core.cginc"

// 法线贴图开关
#define USING_NORMAP_MAP defined(_NORMAL_MAP_ON)

// 自发光开关
#define USING_EMISSION defined(_EMISSION_ON)

// 地面反射效果开关
#define USING_GROUND_REFLECTION defined(_USE_GROUND_REFLECTION)

// PRB开关
#define USING_PRB_LIGHTING defined(_USE_PRB_LIGHTING)

//////////////////////////////////////////////
// 顶点输入数据
struct Attributes
{
	float4 positionOS	: POSITION;
	float2 uv			: TEXCOORD0;
	float3 normalOS		: NORMAL;

#if USING_NORMAP_MAP
	float4 tangentOS    : TANGENT;
#endif
};

//////////////////////////////////////////////
// 片元输入数据
struct Varyings
{
	float4 positionCS	: SV_POSITION;
	float2 uv			: TEXCOORD0;
#if USING_NORMAP_MAP
	float4 normalWS		: TEXCOORD1;	// xyz: normal		z: positionWS.x
	float4 tangentWS	: TEXCOORD2;	// xyz: tangent		z: positionWS.y
	float4 bitangentWS	: TEXCOORD3;	// xyz: bitangent	z: positionWS.z
#else
	float3 positionWS	: TEXCOORD1;
	float3 normalWS		: TEXCOORD2;
#endif

	float4 positionSS	: TEXCOORD4;
};

//////////////////////////////////////////////
// 材质输入
uniform half4 _Color;

uniform half _BumpScale;

uniform half _Roughness;
uniform half _Metallic;
uniform half _AOScale;

uniform half _SpecularIntensity;
uniform half3 _SpecularColor;

uniform half _CubemapIntensity;
uniform half4 _CubemapColor;

uniform half _EmissionIntensity;
uniform half3 _EmissionColor;

//////////////////////////////////////////////
// 贴图
uniform sampler2D _BaseTex;
uniform float4 _BaseTex_ST;

uniform sampler2D _MaskTex;
uniform half4 _MaskTex_ST;

uniform sampler2D _BumpTex;
uniform half4 _BumpTex_ST;

UNITY_DECLARE_TEXCUBE(_CubeMap);
half4 _CubeMap_HDR;

//////////////////////////////////////////////
// 功能函数
#include "../Lib/Functions.cginc"

SurfaceData GetSurfaceData(float2 uv)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(uv, _BaseTex)));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(uv, _MaskTex));
	half3 bumpColor = tex2D(_BumpTex, TRANSFORM_TEX(uv, _BumpTex)).xyz;

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
	outSurfaceData.albedo = baseColor.rgb * _Color.rgb;
	outSurfaceData.alpha = baseColor.a * _Color.a;

	// 法线
#if USING_NORMAP_MAP
	outSurfaceData.normalTS = 2.0 * bumpColor - 1.0;
	outSurfaceData.normalTS.xy *= _BumpScale;
#endif

	// PBR
	outSurfaceData.roughness = _Roughness;
	outSurfaceData.metallic = _Metallic;
	outSurfaceData.occlusion = _AOScale;

	outSurfaceData.specular = _SpecularIntensity * _SpecularColor;

	// 自发光
#if USING_EMISSION
	outSurfaceData.emissionFactor = maskColor.a;
	outSurfaceData.emission = outSurfaceData.albedo * _EmissionIntensity * _EmissionColor;
#endif

	return outSurfaceData;
}

InputData GetInputData(Varyings vertexOutput, SurfaceData surfaceData)
{
	InputData outInputData = GetDefaultInputData();

#if USING_NORMAP_MAP
	outInputData.positionWS = float3(vertexOutput.normalWS.w, vertexOutput.tangentWS.w, vertexOutput.bitangentWS.w);

	half3 normalWS = mul(surfaceData.normalTS, half3x3(vertexOutput.tangentWS.xyz, vertexOutput.bitangentWS.xyz, vertexOutput.normalWS.xyz));
	outInputData.normalWS = normalize(normalWS);
#else
	outInputData.positionWS = vertexOutput.positionWS;
	outInputData.normalWS = normalize(vertexOutput.normalWS);
#endif

	outInputData.positionSS = vertexOutput.positionSS;
	outInputData.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - outInputData.positionWS);

	return outInputData;
}

EnvData GetEnvData(Varyings vertexOutput, InputData inputData, BRDFData brdfData, BxDFContext bxdfContext)
{
	EnvData outEnvData = GetDefaultEnvData();
	outEnvData.ambientColor = _G_DynamicAmbientColor;
	outEnvData.lightColor = _G_LightColor;
	outEnvData.envColor = 6.0 * _CubemapIntensity * _CubemapColor.rgb;
	outEnvData.specularColor = _G_SpecularColor;

	return outEnvData;
}

//////////////////////////////////////////////
// 顶点函数
Varyings vert(Attributes input)
{
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);

	Varyings output = (Varyings)0;
	output.positionCS = vertexInput.positionCS;
	output.uv = input.uv;

#if USING_NORMAP_MAP
	VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	output.normalWS = float4(normalInput.normalWS, vertexInput.positionWS.x);
	output.tangentWS = float4(normalInput.tangentWS, vertexInput.positionWS.y);
	output.bitangentWS = float4(normalInput.bitangentWS, vertexInput.positionWS.z);
#else
	output.positionWS = vertexInput.positionWS;
	output.normalWS = UnityObjectToWorldNormal(input.normalOS);
#endif

#if USING_GROUND_REFLECTION
	output.positionSS = ComputeScreenPos(vertexInput.positionCS);
#endif

	return output;
}

//////////////////////////////////////////////
// 片元函数
half4 frag(Varyings input) : SV_Target
{
	half3 lightDir = normalize(_G_LightDir);
	SurfaceData surfaceData = GetSurfaceData(input.uv);
	InputData inputData = GetInputData(input, surfaceData);
	BxDFContext bxdfContext = GetBxDFContext(inputData, lightDir);
	BRDFData brdfData = GetBRDFData(surfaceData);
	EnvData envData = GetEnvData(input, inputData, brdfData, bxdfContext);

#if USING_PRB_LIGHTING
	half3 color = PBRLighting(surfaceData, brdfData, bxdfContext, envData, UNITY_PASS_TEXCUBE(_CubeMap), _CubeMap_HDR);
#else
	half3 color = SimpleLighting(surfaceData, bxdfContext, envData);
#endif

	// 自发光
#if USING_EMISSION
	color = MixEmission(color, surfaceData);
#endif

	// 地面反射
#if USING_GROUND_REFLECTION
	color = MixGroundReflection(color, inputData);
#endif

	// 与Bloom颜色混合
	color = MixBloomColor(color);

	// 雾
	color = MixFog(color, inputData);

	// 调整场景整体颜色
	color = MixSceneColor(color);

	// Bloom系数
#if USING_EMISSION
	half alpha = GetBloomFactor(surfaceData.alpha, surfaceData.emissionFactor);
#else
	half alpha = GetBloomFactor(surfaceData.alpha);
#endif

	return L2G(half4(color, alpha));
}

#endif
