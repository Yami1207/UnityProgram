#ifndef __BSDF_CGINC__
#define __BSDF_CGINC__

struct BRDFData
{
	// F0 
	half3 fresnel0;

	half3 diffuseColor;

	half3 specularColor;

	// 感性粗糙度(美术输入)
	half perceptualRoughness;

	// perceptualRoughness^2
	// Burley 在"Physically Based Shading at Disney"提出的建议，把美术提供的roughness进行平方后使用在NDF
	half roughness;

	// perceptualRoughness^4
	half roughness2;

	// perceptualRoughness^4 - 1
	half roughness2MinusOne;
};

struct BxDFContext
{
	float NoV;			// -1 to 1
	float NoV_01;		// clamp 0 to 1
	float NoV_abs;

	float NoL;			// -1 to 1
	float NoL_01;		// 0 to 1
	float NoL_abs01;	// abs 0 to 1

	float3 R;			// ReflectVector

	float3 H;			// half dir
	float NoH;
};

BRDFData GetBRDFData(SurfaceData surfaceData)
{
	half3 albedo = surfaceData.albedo;
	half metallic = surfaceData.metallic;
	half roughness = surfaceData.roughness;

	BRDFData data = (BRDFData)0;
	data.fresnel0 = lerp(kDieletricSpec, albedo, metallic);
	data.diffuseColor = albedo * lerp(0.96, 0.0, metallic);
	data.specularColor = data.fresnel0;

	// 粗糙度
	data.perceptualRoughness = roughness;
	data.roughness = max(data.perceptualRoughness * data.perceptualRoughness, 0.002);
	data.roughness2 = data.roughness * data.roughness;
	data.roughness2MinusOne = data.roughness2 - 1;

	return data;
}

BxDFContext GetBxDFContext(InputData inputData, float3 lightDir)
{
	BxDFContext context;

	context.NoV = dot(inputData.normalWS, inputData.viewDirectionWS);
	context.NoV_01 = saturate(context.NoV);
	context.NoV_abs = abs(context.NoV);

	context.NoL = dot(inputData.normalWS, lightDir);
	context.NoL_01 = context.NoL * 0.5 + 0.5;
	context.NoL_abs01 = abs(saturate(context.NoL));

	context.R = reflect(-inputData.viewDirectionWS, inputData.normalWS);

	context.H = SafeNormalize(inputData.viewDirectionWS + lightDir);
	context.NoH = saturate(dot(inputData.normalWS, context.H));

	return context;
}

// 来源: UE 4.25 => EnvBRDFApprox
// 根据UE代码，在计算时传NoV为Clamp01，但在计算ClearCoat时传入NoV_abs01
half3 EnvBRDFApprox(half3 SpecularColor, half Roughness, half NoV)
{
	// [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
	// Adaptation to fit our G term.
	const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
	const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
	half4 r = Roughness * c0 + c1;
	half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
	half2 AB = half2(-1.04, 1.04) * a004 + r.zw;

	// Anything less than 2% is physically impossible and is instead considered to be shadowing
	// Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
	AB.y *= saturate(50.0 * SpecularColor.g);
	return SpecularColor * AB.x + AB.y;
}

#endif
