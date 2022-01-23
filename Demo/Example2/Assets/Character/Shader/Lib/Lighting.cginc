#ifndef __LIGHTING_CGINC__
#define __LIGHTING_CGINC__

#include "BSDF.cginc"
#include "IBLSpecular.cginc"

/////////////////////////////////////////////////////////////////////////
// 顶点光照颜色（unity内置函数）
float3 VertexLighting(float3 positionWS, float3 normalWS)
{
#if 0
	//(u_xlat1.xyz = ((-u_xlat0.xyz) + _XSphereLightCharacterB[1].xyz));
	//(u_xlat16_4.x = dot(u_xlat1.xyz, u_xlat1.xyz));
	//(u_xlat16_12 = sqrt(u_xlat16_4.x));
	//(u_xlat16_4.x = inversesqrt(u_xlat16_4.x));
	//(u_xlat16_20 = (u_xlat16_12 + 1.0));
	//(u_xlat16_20 = (u_xlat16_20 + (-_XSphereLightCharacterA[1].w)));
	//(u_xlat16_20 = max(u_xlat16_20, 9.9999997e-06));
	//(u_xlat16_20 = (1.0 / u_xlat16_20));
	//(u_xlat16_20 = min(u_xlat16_20, 1.0));
	//(u_xlat16_5.xyz = ((u_xlat1.xyz * u_xlat16_4.xxx) + (-u_xlat2.xyz)));
	//(u_xlat16_6.xyz = (u_xlat1.xyz * u_xlat16_4.xxx));
	//(u_xlat16_4.xzw = ((vec3(u_xlat16_20) * u_xlat16_5.xyz) + u_xlat2.xyz));
	//(u_xlat16_4.x = dot(u_xlat16_6.xyz, u_xlat16_4.xzw));
	//(u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0));
	//(u_xlat16_20 = max(_XSphereLightCharacterB[1].w, 9.9999997e-06));
	//(u_xlat16_12 = (u_xlat16_12 / u_xlat16_20));
	//(u_xlat16_12 = min(u_xlat16_12, 1.0));
	//(u_xlat16_12 = ((-u_xlat16_12) + 1.0));
	//(u_xlat16_4.x = (u_xlat16_12 * u_xlat16_4.x));
	//(u_xlat16_4.xyz = (u_xlat16_4.xxx * _XSphereLightCharacterA[1].xyz));
	//(u_xlat1.xyz = ((-u_xlat0.xyz) + _XSphereLightCharacterB[0].xyz));
	//(u_xlat0.xyz = ((-u_xlat0.xyz) + _XSphereLightCharacterB[2].xyz));
	//(u_xlat16_28 = dot(u_xlat1.xyz, u_xlat1.xyz));
	//(u_xlat16_5.x = sqrt(u_xlat16_28));
	//(u_xlat16_28 = inversesqrt(u_xlat16_28));
	//(u_xlat16_13.x = (u_xlat16_5.x + 1.0));
	//(u_xlat16_13.x = (u_xlat16_13.x + (-_XSphereLightCharacterA[0].w)));
	//(u_xlat16_13.x = max(u_xlat16_13.x, 9.9999997e-06));
	//(u_xlat16_13.x = (1.0 / u_xlat16_13.x));
	//(u_xlat16_13.x = min(u_xlat16_13.x, 1.0));
	//(u_xlat16_6.xyz = ((u_xlat1.xyz * vec3(u_xlat16_28)) + (-u_xlat2.xyz)));
	//(u_xlat16_7.xyz = (u_xlat1.xyz * vec3(u_xlat16_28)));
	//(u_xlat16_13.xyz = ((u_xlat16_13.xxx * u_xlat16_6.xyz) + u_xlat2.xyz));
	//(u_xlat16_28 = dot(u_xlat16_7.xyz, u_xlat16_13.xyz));
	//(u_xlat16_28 = clamp(u_xlat16_28, 0.0, 1.0));
	//(u_xlat16_13.x = max(_XSphereLightCharacterB[0].w, 9.9999997e-06));
	//(u_xlat16_5.x = (u_xlat16_5.x / u_xlat16_13.x));
	//(u_xlat16_5.x = min(u_xlat16_5.x, 1.0));
	//(u_xlat16_5.x = ((-u_xlat16_5.x) + 1.0));
	//(u_xlat16_28 = (u_xlat16_28 * u_xlat16_5.x));
	//(u_xlat16_4.xyz = ((vec3(u_xlat16_28) * _XSphereLightCharacterA[0].xyz) + u_xlat16_4.xyz));
	//(u_xlat16_28 = dot(u_xlat0.xyz, u_xlat0.xyz));
	//(u_xlat16_5.x = inversesqrt(u_xlat16_28));
	//(u_xlat16_28 = sqrt(u_xlat16_28));
	//(u_xlat16_13.xyz = ((u_xlat0.xyz * u_xlat16_5.xxx) + (-u_xlat2.xyz)));
	//(u_xlat16_6.xyz = (u_xlat0.xyz * u_xlat16_5.xxx));
	//(u_xlat16_5.x = (u_xlat16_28 + 1.0));
	//(u_xlat16_5.x = (u_xlat16_5.x + (-_XSphereLightCharacterA[2].w)));
	//(u_xlat16_5.x = max(u_xlat16_5.x, 9.9999997e-06));
	//(u_xlat16_5.x = (1.0 / u_xlat16_5.x));
	//(u_xlat16_5.x = min(u_xlat16_5.x, 1.0));
	//(u_xlat16_5.xyz = ((u_xlat16_5.xxx * u_xlat16_13.xyz) + u_xlat2.xyz));
	//(u_xlat16_5.x = dot(u_xlat16_6.xyz, u_xlat16_5.xyz));
	//(u_xlat16_5.x = clamp(u_xlat16_5.x, 0.0, 1.0));
	//(u_xlat16_13.x = max(_XSphereLightCharacterB[2].w, 9.9999997e-06));
	//(u_xlat16_28 = (u_xlat16_28 / u_xlat16_13.x));
	//(u_xlat16_28 = min(u_xlat16_28, 1.0));
	//(u_xlat16_28 = ((-u_xlat16_28) + 1.0));
	//(u_xlat16_28 = (u_xlat16_28 * u_xlat16_5.x));
	//(vs_TEXCOORD5.xyz = ((vec3(u_xlat16_28) * _XSphereLightCharacterA[2].xyz) + u_xlat16_4.xyz));
#endif

	float3 color = float3(0, 0, 0);
	for (int i = 0; i < 3; ++i)
	{
		float3 lightDir = _XSphereLightCharacterB[i].xyz - positionWS;
		float distance = sqrt(dot(lightDir, lightDir));
		float3 normalLightDir = lightDir / distance;

		float maxDistance = max(distance + 1.0 - _XSphereLightCharacterA[i].w, 9.9999997e-06);
		float factor = min(1.0 / maxDistance, 1.0);
		float3 newNormal = (normalLightDir - normalWS) * factor + normalWS;
		float ndl = saturate(dot(normalLightDir, newNormal));

		float range = max(_XSphereLightCharacterB[i].w, 9.9999997e-06);
		range = min(distance / range, 1.0);
		range = (1 - range) * ndl;

		color += range * _XSphereLightCharacterA[i].xyz;
	}

	return color;
}

/////////////////////////////////////////////////////////////////////////
// PBR
half3 LightingPhysicallyBased(SurfaceData surfaceData, BRDFData brdfData, BxDFContext bxdfContext, EnvData envData, UNITY_ARGS_TEXCUBE(tex), half4 hdr)
{
	half3 envReflection = CalcGlossyEnvironmentReflection(bxdfContext.R, brdfData.perceptualRoughness, UNITY_PASS_TEXCUBE(tex), hdr);
	half3 brdf = EnvBRDFApprox(brdfData.specularColor, brdfData.perceptualRoughness, bxdfContext.NoV_01);
	half3 specularTerm = brdf * envReflection * envData.envColor;

	// GGX
	// D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
	float d = bxdfContext.NoH * bxdfContext.NoH * brdfData.roughness2MinusOne + 1.0;
	half directSpecular = brdfData.roughness2 / (d * d + 1e-07) * INV_PI;

	half3 directLightColor = directSpecular * brdf;
	directLightColor = envData.directLightColor * (directLightColor * envData.directLightIntensity + specularTerm);

	half3 indirectLightColor = brdfData.diffuseColor * envData.indirectLightColor * envData.indirectLightIntensity;
	indirectLightColor += specularTerm;

#if defined(L_AO_ON)
	indirectLightColor = surfaceData.occlusion * indirectLightColor;
#endif

	return directLightColor * saturate(bxdfContext.NoL) + indirectLightColor;
}

/////////////////////////////////////////////////////////////////////////
// 返回第一层阴影mask值
half GetFirstShadowMask(InputData inputData, SurfaceData surfaceData, BxDFContext bxdfContext)
{
	half2 tempXY = surfaceData.shadowMask * half2(1.2, 1.25) - half2(0.1, 0.12);
	half mask = 1.0 - floor(1.5 - surfaceData.shadowMask);
	mask = lerp(tempXY.y, tempXY.x, mask);
	mask = bxdfContext.NoL_01 + mask;

#if defined(SHADOW_SMOOTH_ON)
	// 阴影平滑
	half smoothRange = surfaceData.shadowSmooth + surfaceData.shadowSmooth;
	mask = 0.5 * mask - surfaceData.firstShadow.w;
	mask = clamp(mask, -surfaceData.shadowSmooth, surfaceData.shadowSmooth);
	mask = (mask + surfaceData.shadowSmooth) / (smoothRange);
#else
	mask = floor(1.0 + 0.5 * mask - surfaceData.firstShadow.w);
#endif

	return 1.0 - (1 - inputData.isShadow) * mask;
}

/////////////////////////////////////////////////////////////////////////
// 漫反射
half3 LightingDiffuse(InputData inputData, SurfaceData surfaceData, BxDFContext bxdfContext)
{
	half firstFactor = GetFirstShadowMask(inputData, surfaceData, bxdfContext);
	half3 firstShadowColor = surfaceData.albedo * surfaceData.firstShadow.xyz;
	half3 color = lerp(surfaceData.albedo * surfaceData.diffuse, firstShadowColor, firstFactor);

	half secondShadowFactor = bxdfContext.NoL_01 + surfaceData.shadowMask;
	secondShadowFactor = 1.0 - floor(1.0 + secondShadowFactor * 0.5 - surfaceData.secondShadow.w);
	half3 secondShadowColor = surfaceData.albedo * surfaceData.secondShadow.xyz;
	secondShadowColor = lerp(firstShadowColor, secondShadowColor, secondShadowFactor);

	// 两层阴影之间过渡
	half shadowFactor = 1.0 - floor(surfaceData.shadowMask + 0.9);
	color = lerp(color, secondShadowColor, shadowFactor);
	return color;
}

/////////////////////////////////////////////////////////////////////////
// 高光
half3 LightingSpecular(SurfaceData surfaceData, BxDFContext bxdfContext)
{
#if 0
	//(u_xlat24 = dot(u_xlat1.xyz, u_xlat1.xyz));
	//(u_xlat24 = inversesqrt(u_xlat24));
	//(u_xlat1.xyz = (vec3(u_xlat24) * u_xlat1.xyz));
	//(u_xlat0.x = dot(u_xlat0.xyz, u_xlat1.xyz));
	//(u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
	//(u_xlat0.x = max(u_xlat0.x, 9.9999997e-05));
	//(u_xlat0.x = log2(u_xlat0.x));
	//(u_xlat0.x = (u_xlat0.x * _SpecularShiness));
	//(u_xlat0.x = exp2(u_xlat0.x));
	//(u_xlat0.x = ((-u_xlat0.x) + u_xlat16_3.y));
	//(u_xlat0.x = floor(u_xlat0.x));
	//(u_xlat0.x = ((-u_xlat0.x) + 1.0));
	//(u_xlat0.x = max(u_xlat0.x, 0.0));
	//(u_xlat8.x = (u_xlat16_2.z * _SpecularIntensity));
	//(u_xlat8.xyz = (u_xlat4.xyz * u_xlat8.xxx));
	//(u_xlat8.xyz = (u_xlat8.xyz * vec3(_SpecularColor.x, _SpecularColor.y, _SpecularColor.z)));
	//(u_xlat0.xyz = (u_xlat8.xyz * u_xlat0.xxx));
	//(u_xlat0.xyz = ((u_xlat0.xyz * _XGlobalCharSpecularColor.xyz) + u_xlat3.xzw));
#endif
	half spec = pow(max(bxdfContext.NoH, 0.00009), surfaceData.specGloss);
	spec = max(1 - floor(2.0 - surfaceData.specMask - spec), 0.0);
	half3 specColor = surfaceData.albedo * surfaceData.specular * _XGlobalCharSpecularColor;
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
#if 0
	//(u_xlat5.x = vs_TEXCOORD1.w);
	//(u_xlat5.y = vs_TEXCOORD2.w);
	//(u_xlat5.z = vs_TEXCOORD3.w);
	//(u_xlat5.xyz = ((-u_xlat5.xyz) + _WorldSpaceCameraPos.xyz));
	//(u_xlat24 = dot(u_xlat5.xyz, u_xlat5.xyz));
	//(u_xlat24 = inversesqrt(u_xlat24));
	//(u_xlat5.xyz = (vec3(u_xlat24) * u_xlat5.xyz));
	//(u_xlat16_24 = dot(u_xlat0.xyz, u_xlat5.xyz));
	//(u_xlat16_7.x = ((-abs(u_xlat16_24)) + 1.0));
	//(u_xlat16_7.x = max(u_xlat16_7.x, 0.001));
	//(u_xlat16_7.x = log2(u_xlat16_7.x));
	//(u_xlat16_7.x = (u_xlat16_7.x * _EffectRimFading));
	//(u_xlat16_7.x = exp2(u_xlat16_7.x));
	//(u_xlat16_7.xyz = (u_xlat16_7.xxx * _EffectRimColor.xyz));
	//(u_xlat16_7.xyz = ((vec3(vec3(_EffectRimTransparency, _EffectRimTransparency, _EffectRimTransparency)) * u_xlat16_7.xyz) + u_xlat0.xyz));
#endif
	half rim = pow(max(1 - bxdfContext.NoV_abs, 0.001), surfaceData.rimFading);
	return fragColor + rim * surfaceData.rimColor;
}

#endif
