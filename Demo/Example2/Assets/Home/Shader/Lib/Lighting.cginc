#ifndef __LIGHTING_CGINC__
#define __LIGHTING_CGINC__

#include "BSDF.cginc"
#include "IBLSpecular.cginc"

/////////////////////////////////////////////////////////////////////////
// 顶点光照颜色（unity内置函数）
float3 VertexLighting(float3 positionWS, float3 normalWS)
{
	float3 color = float3(0, 0, 0);
	for (int i = 0; i < 3; ++i)
	{
		float3 lightDir = _G_SphereLightCharacterB[i].xyz - positionWS;
		float distance = sqrt(dot(lightDir, lightDir));
		float3 normalLightDir = lightDir / distance;

		float maxDistance = max(distance + 1.0 - _G_SphereLightCharacterA[i].w, 9.9999997e-06);
		float factor = min(1.0 / maxDistance, 1.0);
		float3 newNormal = (normalLightDir - normalWS) * factor + normalWS;
		float ndl = saturate(dot(normalLightDir, newNormal));

		float range = max(_G_SphereLightCharacterB[i].w, 9.9999997e-06);
		range = min(distance / range, 1.0);
		range = (1 - range) * ndl;

		color += range * _G_SphereLightCharacterA[i].xyz;
	}

	return color;
}

/////////////////////////////////////////////////////////////////////////
// 简单光照模型（漫反射 + 环境光）
half3 SimpleLighting(SurfaceData surfaceData, BxDFContext bxdfContext, EnvData envData)
{
	half3 color = saturate(bxdfContext.NoL) * envData.lightColor + envData.ambientColor;
	return color * surfaceData.albedo;
}

/////////////////////////////////////////////////////////////////////////
// PBR
half3 PBRLighting(SurfaceData surfaceData, BRDFData brdfData, BxDFContext bxdfContext, EnvData envData, UNITY_ARGS_TEXCUBE(tex), half4 hdr)
{
	half3 envReflection = CalcGlossyEnvironmentReflection(bxdfContext.R, brdfData.perceptualRoughness, UNITY_PASS_TEXCUBE(tex), hdr);
	half3 brdf = EnvBRDFApprox(brdfData.specularColor, brdfData.perceptualRoughness, bxdfContext.NoV_01);
	half3 specularTerm = brdf * envReflection;

	half3 indirectLightColor = specularTerm * envData.specularColor * envData.envColor * surfaceData.occlusion;

	// GGX
	// D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
	float d = bxdfContext.NoH * bxdfContext.NoH * brdfData.roughness2MinusOne + 1.0;
	half directSpecular = brdfData.roughness2 / (d * d + 1e-07) * INV_PI;
	half3 directLightColor = directSpecular * brdf * envData.lightColor;

	half NoL = saturate(bxdfContext.NoL);
	half3 color = NoL * envData.lightColor + envData.ambientColor * surfaceData.occlusion;
	color *= brdfData.diffuseColor;
	color += directLightColor * NoL + indirectLightColor;
	return color;
}

/////////////////////////////////////////////////////////////////////////
// 返回第一层阴影mask值
half GetFirstShadowMask(SurfaceData surfaceData, BxDFContext bxdfContext)
{
	half2 tempXY = surfaceData.lightMask * half2(1.2, 1.25) - half2(0.1, 0.12);
	half mask = 1.0 - floor(1.5 - surfaceData.lightMask);
	mask = lerp(tempXY.y, tempXY.x, mask);
	mask = bxdfContext.NoL_01 + mask;

#ifdef _SHADOW_SMOOTH_ON
	// 阴影平滑
	half smoothRange = surfaceData.shadowSmooth + surfaceData.shadowSmooth;
	mask = 0.5 * mask - surfaceData.firstShadowThreshold;
	mask = clamp(mask, -surfaceData.shadowSmooth, surfaceData.shadowSmooth);
	mask = (mask + surfaceData.shadowSmooth) / (smoothRange);
#else
	mask = floor(1.0 + 0.5 * mask - surfaceData.firstShadowThreshold);
#endif

	return 1.0 - mask;
}

/////////////////////////////////////////////////////////////////////////
// 角色漫反射
half3 Actor_LightingDiffuse(half3 skinColor, SurfaceData surfaceData, BxDFContext bxdfContext, EnvData envData)
{
	half firstFactor = GetFirstShadowMask(surfaceData, bxdfContext) * envData.shadowIntensity;
	half3 color = lerp(surfaceData.noShadowColor, surfaceData.firstShadowColor, firstFactor);

	half secondShadowFactor = bxdfContext.NoL_01 + surfaceData.lightMask;
	secondShadowFactor = (1.0 - floor(1.0 + 0.5 * secondShadowFactor - surfaceData.secondShadowThreshold)) * envData.shadowIntensity;
	half3 shadowColor = lerp(surfaceData.firstShadowColor, surfaceData.secondShadowColor, secondShadowFactor);

	half factor = (1.0 - floor(surfaceData.lightMask + 0.9)) * envData.shadowIntensity;
	color = lerp(color, shadowColor, factor);
	return skinColor * color;
}

/////////////////////////////////////////////////////////////////////////
// 角色高光
half3 Actor_LightingSpecular(half3 skinColor, SurfaceData surfaceData, BxDFContext bxdfContext, EnvData envData)
{
	half spec = pow(max(bxdfContext.NoH, 0.00009), surfaceData.specGloss);
	spec = max(1 - floor(2.0 - surfaceData.specMask - spec), 0.0);
	half3 specColor = skinColor * surfaceData.specular * envData.specularColor;
	return spec * specColor;
}

/////////////////////////////////////////////////////////////////////////
// 自发光
half3 MixEmission(half3 fragColor, SurfaceData surfaceData)
{
	return fragColor + surfaceData.emission * surfaceData.emissionFactor;
}

/////////////////////////////////////////////////////////////////////////
// 边缘光
half3 MixRimLight(half3 fragColor, SurfaceData surfaceData, BxDFContext bxdfContext)
{
	half rim = pow(max(1 - bxdfContext.NoV_abs, 0.001), surfaceData.rimFading);
	return fragColor + rim * surfaceData.rimColor;
}

#endif
