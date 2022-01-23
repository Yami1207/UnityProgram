#ifndef __CHARACTER_EYE_PASS_CGINC__
#define __CHARACTER_EYE_PASS_CGINC__

#include "CharacterInput.cginc"

SurfaceData GetSurfaceData(float2 uv)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(uv, _BaseTex)));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(uv, _MaskTex));	// R:高光范围 G:自投影区域 B:高光 A:自发光
	half3 normalColor = tex2D(_NormalTex, TRANSFORM_TEX(uv, _NormalTex)).xyz;// UnpackNormal()).xyz;

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
	outSurfaceData.albedo = baseColor.rgb * _AlbedoColor.rgb;
	outSurfaceData.alpha = GetSurfaceAlpha(baseColor.a);

	// 法线
	outSurfaceData.normalTS = 2.0 * normalColor - 1.0;
	outSurfaceData.normalTS.xy *= _BumpScale;

	outSurfaceData.diffuse = _NoShadowColor.rgb * _XGlobalCharacterNoShadowColor.rgb;

	// 阴影
	outSurfaceData.shadowMask = maskColor.g;
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

	return outSurfaceData;
}

InputData GetInputData(Varyings vertexOutput, SurfaceData surfaceData)
{
	InputData outInputData = GetDefaultInputData();
	outInputData.positionWS = vertexOutput.positionWSAndFogCoord.xyz;
	outInputData.fogCoord = vertexOutput.positionWSAndFogCoord.w;
	outInputData.isShadow = 0.0;

#if defined(USE_NORMAL_MAP)
	half3 normalWS = mul(surfaceData.normalTS, half3x3(vertexOutput.tangentWS, vertexOutput.bitangentWS, vertexOutput.normalWS));
#else
	half3 normalWS = vertexOutput.normalWS;
#endif
	outInputData.normalWS = SafeNormalize(normalWS);

	outInputData.viewDirectionWS = SafeNormalize(_WorldSpaceCameraPos.xyz - outInputData.positionWS);
	outInputData.vertexLighting = vertexOutput.vertexLighting;

	return outInputData;
}

half4 frag(Varyings input) : SV_Target
{
	half3 lightDir = SafeNormalize(_XGlobalCharacterLightDir);

	SurfaceData surfaceData = GetSurfaceData(input.uv);
	InputData inputData = GetInputData(input, surfaceData);
	BxDFContext bxdfContext = GetBxDFContext(inputData, lightDir);
	BRDFData brdfData = GetBRDFData(surfaceData);

	// 漫反射
	half3 color = LightingDiffuse(inputData, surfaceData, bxdfContext);

	// 高光
	color += LightingSpecular(surfaceData, bxdfContext);

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
