#ifndef __FUNCTIONS_CGINC__
#define __FUNCTIONS_CGINC__

//////////////////////////////////////////////
// 返回a通道
inline half GetSurfaceAlpha(half alpha)
{
	return alpha;
}

/////////////////////////////////////////////////////////////////////////
//
half3 CalcSkinRimColor(InputData inputData, SurfaceData surfaceData, BxDFContext bxdfContext, half2 rimRange, half2 distanceRange, half intensity, half threshold)
{
	half NoL_01 = saturate(dot(inputData.normalWS, _GlobalRimLightDir));
	half3 u_xlat33 = inputData.positionWS - _WorldSpaceCameraPos.xyz;
	half factor = smoothstep(distanceRange.x, distanceRange.y, dot(u_xlat33, u_xlat33));
	factor = NoL_01 * (1 - _GlobalEnableDistanceRim * factor);
	
	half rim = smoothstep(rimRange.x, rimRange.y, 1 - bxdfContext.NoV_01);
	rim = intensity * rim * step(0.0, bxdfContext.NoV + threshold);

	half3 color = rim * surfaceData.skinRimColor * factor;
	return color * _XGlobalCharacterSkinRimColor;
}

/////////////////////////////////////////////////////////////////////////
// 处理MatCap
half3 CalcMatCap(InputData inputData, SurfaceData surfaceData, half scale, sampler2D matcapTex)
{
	half3 normalOS = mul(unity_WorldToObject, inputData.normalWS);
	half4 normal = mul(UNITY_MATRIX_IT_MV, half4(normalOS, 0.0));
	normal.y = lerp(normal.y, inputData.normalWS.y, scale);
	normal.xyz = SafeNormalize(normal.xyz);

	half4 matCap = G2L(tex2D(matcapTex, 0.5 * normal.xy + 0.5));
	return matCap.rgb * surfaceData.specMask;
}

/////////////////////////////////////////////////////////////////////////
// 处理Ambient
inline half3 MixAmbient(half3 color)
{
#if 0
	//(u_xlat1.xyz = (_XGlobalCharacterAmbientColor.xyz * _GlobalTint.xyz));
	//(u_xlat1.xyz = (u_xlat1.xyz * u_xlat16_4.xyz));
#endif
	return color * _XGlobalCharacterAmbientColor.rgb * _GlobalTint.rgb;
}

/////////////////////////////////////////////////////////////////////////
// 处理bloom颜色
half3 MixBloomColor(half3 color)
{
#if 0
	//(u_xlat2.xyz = (u_xlat1.xyz * _BloomModColor.xyz));
	//(u_xlat2.xyz = ((u_xlat2.xyz * vec3(_BloomModIntensity)) + (-u_xlat1.xyz)));
	//(u_xlat0.xyz = ((vec3(vec3(_XPostBloom, _XPostBloom, _XPostBloom)) * u_xlat2.xyz) + u_xlat1.xyz));
#endif
	return lerp(color, color * _BloomModColor * _BloomModIntensity, _XPostBloom);
}

/////////////////////////////////////////////////////////////////////////
// 处理bloom系数
half MixBloomAlpha(half alpha, half mask)
{
#if 0
	//(u_xlat0.w = (u_xlat3.w * _BloomFactor));
	//(u_xlat2.x = ((-_BloomFactor) + _EmissionBloomFactor));
	//(u_xlat1.w = ((u_xlat2.x * u_xlat16_7.w) + _BloomFactor));
	//(u_xlat0 = (u_xlat0 + u_xlat1));
	//(u_xlat0.w = max(u_xlat0.w, 0.0));
#endif
	alpha = alpha * _BloomFactor;
	alpha += lerp(_BloomFactor, _EmissionBloomFactor, mask);
	return max(alpha, 0.0);
}

half MixAlpha(SurfaceData surfaceData)
{
#if defined(MIX_ALPHA_OFF)
	return max(surfaceData.alpha, 0.0);
#else
#if 0
	//(u_xlat0.w = (u_xlat3.w * _BloomFactor));
	//(u_xlat2.x = ((-_BloomFactor) + _EmissionBloomFactor));
	//(u_xlat1.w = ((u_xlat2.x * u_xlat16_7.w) + _BloomFactor));
	//(u_xlat0 = (u_xlat0 + u_xlat1));
	//(u_xlat0.w = max(u_xlat0.w, 0.0));
#endif
	half alpha = surfaceData.alpha * _BloomFactor;
	alpha += lerp(_BloomFactor, _EmissionBloomFactor, surfaceData.emissionFactor);
	return max(alpha, 0.0);
#endif
}

/////////////////////////////////////////////////////////////////////////
// 处理雾
uniform half4 _LinearFogColor;
uniform half4 _LinearFogParams;

half ComputeFogFactor(float z)
{
	return z;
}

half3 MixFog(half3 color, InputData inputData)
{
#if 0
	//(u_xlat0 = (u_xlat0 + (-_LinearFogColor)));
	//(u_xlat1.x = max(vs_TEXCOORD6, 0.0));
	//(u_xlat1.x = ((u_xlat1.x * _LinearFogParams.x) + _LinearFogParams.y));
	//(u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0));
	//(SV_Target0 = ((u_xlat1.xxxx * u_xlat0) + _LinearFogColor));
#endif

#if 0
	half fog = max(inputData.fogCoord, 0.0);
	fog = saturate(fog * _LinearFogParams.x + _LinearFogParams.y);
	return lerp(_LinearFogColor, color, fog);
#endif
	return color;
}

/////////////////////////////////////////////////////////////////////////
// 处理雾
inline half4 FinalColor(half3 color, half alpha)
{
	return L2G(half4(color, alpha));
}

#endif
