#ifndef __CHARACTER_HAIR_PASS_CGINC__
#define __CHARACTER_HAIR_PASS_CGINC__

#include "CharacterInput.cginc"

SurfaceData GetSurfaceData(Varyings input)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(input.uv.xy, _BaseTex)));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(input.uv.xy, _MaskTex));	// R:高光范围 G:自投影区域 B:高光 A:自发光
	half3 normalColor = tex2D(_NormalTex, TRANSFORM_TEX(input.uv.xy, _NormalTex)).xyz;// UnpackNormal()).xyz;

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
	outSurfaceData.albedo = baseColor.rgb * _AlbedoColor.rgb;
	outSurfaceData.alpha = GetSurfaceAlpha(baseColor.a);

	// 法线
	outSurfaceData.normalTS = 2.0 * normalColor - 1.0;
	outSurfaceData.normalTS.xy *= _BumpScale;

	outSurfaceData.diffuse = _NoShadowColor.rgb * _XGlobalCharacterNoShadowColor.rgb;

	// 阴影
#if defined(USE_VERTEX_COLOR)
	outSurfaceData.shadowMask = 2.0 * input.color.y + maskColor.y;
	outSurfaceData.shadowMask = saturate(outSurfaceData.shadowMask - 1.0);
#else
	outSurfaceData.shadowMask = maskColor.g;
#endif
	outSurfaceData.shadowSmooth = _SmoothFactor;
	outSurfaceData.firstShadow = half4(_FirstShadowColor.rgb * _XGlobalCharacterSkinOneShadowColor.rgb, _FirstShadow);
	outSurfaceData.secondShadow = half4(_SecondShadowColor.rgb * _XGlobalCharacterSkinTwoShadowColor.rgb, _SecondShadow);

	// 高光
	outSurfaceData.specMask = maskColor.r;
	outSurfaceData.specGloss = _SpecularShiness;
	outSurfaceData.specular = maskColor.b * _SpecularIntensity * _SpecularColor;

	// 自发光
	outSurfaceData.emissionFactor = maskColor.a;
	outSurfaceData.emission = outSurfaceData.albedo * _EmissionIntensity * _EmissionColor.rgb;

	// 边缘光
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
	outInputData.isShadow = 0.0;

	outInputData.normalWS = SafeNormalize(vertexOutput.normalWS);

	outInputData.viewDirectionWS = SafeNormalize(_WorldSpaceCameraPos.xyz - outInputData.positionWS);
	outInputData.vertexLighting = vertexOutput.vertexLighting;

	return outInputData;
}

half4 frag(Varyings input) : SV_Target
{
	half3 lightDir = SafeNormalize(_XGlobalCharacterLightDir);

	SurfaceData surfaceData = GetSurfaceData(input);
	InputData inputData = GetInputData(input, surfaceData);
	BxDFContext bxdfContext = GetBxDFContext(inputData, lightDir);
	BRDFData brdfData = GetBRDFData(surfaceData);

	half2 skinRampUV = half2(bxdfContext.NoL_01, 0.5);
	half3 skinRampColor = G2L(tex2D(_SkinRamp, skinRampUV)).xyz;
	half3 skinColor = _SkinIntensity * skinRampColor * surfaceData.albedo;
	surfaceData.albedo = lerp(surfaceData.albedo, skinColor * _SkinColor.rgb, _SkinRate);

	// 漫反射
	half3 color = LightingDiffuse(inputData, surfaceData, bxdfContext);

	half firstShadowMask = GetFirstShadowMask(inputData, surfaceData, bxdfContext);
	half shadowFactor = 1.0 - floor(surfaceData.shadowMask + 0.9);
	half u_xlat21 = step(0.00009, firstShadowMask + shadowFactor);

	// 高光（头发高光计算不一样，要独立出来）
	half specular = pow(1 - max(bxdfContext.NoH, 0.00009), surfaceData.specGloss);
	specular = max(1 - floor(2.0 - surfaceData.specMask - specular), 0.0);
	specular = lerp(specular, _SpecularShadowIntensity * specular, u_xlat21);
	color += skinColor * specular * surfaceData.specular;

	color += CalcSkinRimColor(inputData, surfaceData, bxdfContext, half2(_RimMin, _RimMax), half2(_RimDistanceMin, _RimDistanceMax), _RimIntensity, _RimThreshold);
	
	color *= _XGlobalCharacterLightColor.rgb;
	color += color * input.vertexLighting;

	// 自发光
	color = MixEmission(color, surfaceData);

	// 边缘光
	color = MixRimLight(color, surfaceData, bxdfContext);

	// 环境光
	color = MixAmbient(color);

	// Bloom
	color = MixBloomColor(color);

	// 雾
	color = MixFog(color, inputData);

	// 透明度
	half alpha = MixAlpha(surfaceData);

	return FinalColor(color, alpha);
}

#endif
