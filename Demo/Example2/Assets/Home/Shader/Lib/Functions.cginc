#ifndef __FUNCTIONS_CGINC__
#define __FUNCTIONS_CGINC__

/////////////////////////////////////////////////////////////////////////
// 处理Ambient
half3 MixAmbient(half3 color)
{
	return color * _G_CharacterAmbientColor * _G_TintColor;
}

/////////////////////////////////////////////////////////////////////////
// 地面反射
uniform half _ReflectIntensity;

half3 MixGroundReflection(half3 color, InputData inputData)
{
	float2 uv = (inputData.positionSS.xy + inputData.normalWS.xz) / inputData.positionSS.w;
	half3 reflectColor = G2L(tex2D(_G_GroundReflectionTex, uv));
	return lerp(color, reflectColor, _ReflectIntensity);
}

/////////////////////////////////////////////////////////////////////////
// 计算出指定方向的边缘光
half3 CalcSkinRimColor(InputData inputData, SurfaceData surfaceData, BxDFContext bxdfContext, half2 rimRange, half2 distanceRange, half intensity, half threshold)
{
	half NoL_01 = saturate(dot(inputData.normalWS, _G_RimLightDir));
	half3 u_xlat33 = inputData.positionWS - _WorldSpaceCameraPos.xyz;
	half factor = smoothstep(distanceRange.x, distanceRange.y, dot(u_xlat33, u_xlat33));
	factor = NoL_01 * (1 - _G_EnableDistanceRim * factor);

	half rim = smoothstep(rimRange.x, rimRange.y, 1 - bxdfContext.NoV_01);
	rim = intensity * rim * step(0.0, bxdfContext.NoV + threshold);

	half3 color = rim * surfaceData.skinRimColor * factor;
	return color * _G_CharacterRimColor;
}

/////////////////////////////////////////////////////////////////////////
// 处理Bloom颜色
uniform half _BloomModIntensity;
uniform half3 _BloomModColor;

half3 MixBloomColor(half3 color)
{
	return lerp(color, color * _BloomModColor * _BloomModIntensity, _G_PostBloom);
}

/////////////////////////////////////////////////////////////////////////
// 处理Bloom系数
uniform half _BloomFactor;
uniform half _EmissionBloomFactor;

half GetBloomFactor(half alpha)
{
	return max(alpha * _BloomFactor, 0.0);	
}

half GetBloomFactor(half alpha, half emissionFactor)
{
	alpha *= _BloomFactor;
	alpha += lerp(_BloomFactor, _EmissionBloomFactor, emissionFactor);
	return max(alpha, 0.0);
}

/////////////////////////////////////////////////////////////////////////
// 雾
half3 MixFog(half3 color, InputData inputData)
{
#if 0
	// 线性雾
	(u_xlat0 = (u_xlat1 + (-_SceneLinearFogColor)));
	(u_xlat1.x = max(vs_TEXCOORD5, 0.0));
	(u_xlat1.x = ((u_xlat1.x * _SceneLinearFogParams.x) + _SceneLinearFogParams.y));
	(u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0));
	(u_xlat0 = ((u_xlat1.xxxx * u_xlat0) + _SceneLinearFogColor));
#endif
	return color;
}

/////////////////////////////////////////////////////////////////////////
// 处理场景整体颜色
half3 MixSceneColor(half3 color)
{
	half temp = dot(color.xy, half2(0.3, 0.59));
	color = lerp(color, 0.11 * color + temp.xxx, _G_SceneGray);
	color = lerp(color, color * _G_SceneDarkColor.rgb, _G_SceneDarkColor.w);
	return color;
}

#endif
