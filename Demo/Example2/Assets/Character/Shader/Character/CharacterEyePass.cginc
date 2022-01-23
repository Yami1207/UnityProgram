#ifndef __CHARACTER_EYE_PASS_CGINC__
#define __CHARACTER_EYE_PASS_CGINC__

#include "CharacterInput.cginc"

SurfaceData GetSurfaceData(float2 uv)
{
	half4 baseColor = G2L(tex2D(_BaseTex, TRANSFORM_TEX(uv, _BaseTex)));
	half4 maskColor = tex2D(_MaskTex, TRANSFORM_TEX(uv, _MaskTex));	// R:�߹ⷶΧ G:��ͶӰ���� B:�߹� A:�Է���
	half3 normalColor = tex2D(_NormalTex, TRANSFORM_TEX(uv, _NormalTex)).xyz;// UnpackNormal()).xyz;

	SurfaceData outSurfaceData = GetDefaultSurfaceData();
	outSurfaceData.albedo = baseColor.rgb * _AlbedoColor.rgb;
	outSurfaceData.alpha = GetSurfaceAlpha(baseColor.a);

	// ����
	outSurfaceData.normalTS = 2.0 * normalColor - 1.0;
	outSurfaceData.normalTS.xy *= _BumpScale;

	outSurfaceData.diffuse = _NoShadowColor.rgb * _XGlobalCharacterNoShadowColor.rgb;

	// ��Ӱ
	outSurfaceData.shadowMask = maskColor.g;
	outSurfaceData.shadowSmooth = _SmoothFactor;
	outSurfaceData.firstShadow = half4(_FirstShadowColor.rgb * _XGlobalCharacterSkinOneShadowColor.rgb, _FirstShadow);
	outSurfaceData.secondShadow = half4(_SecondShadowColor.rgb * _XGlobalCharacterSkinTwoShadowColor.rgb, _SecondShadow);

	// �߹�
	outSurfaceData.specMask = maskColor.r;
	outSurfaceData.specGloss = _SpecularShiness;
	outSurfaceData.specular = maskColor.b * _SpecularIntensity * _SpecularColor;

	// �Է���
	outSurfaceData.emissionFactor = maskColor.a;
	outSurfaceData.emission = outSurfaceData.albedo * _EmissionIntensity * _EmissionColor.rgb;

	// ��Ե��
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

	// ������
	half3 color = LightingDiffuse(inputData, surfaceData, bxdfContext);

	// �߹�
	color += LightingSpecular(surfaceData, bxdfContext);

	color *= _XGlobalCharacterLightColor.rgb;
	color += color * input.vertexLighting;

	// �Է���
	color = MixEmission(color, surfaceData);

	// ��Ե��
	color = MixRimLight(color, surfaceData, bxdfContext);

	// ������
	color = MixAmbient(color);

	// Bloom
	color = MixBloomColor(color);

	// ��
	color = MixFog(color, inputData);

	// ͸����
	half alpha = MixAlpha(surfaceData);

	return FinalColor(color, alpha);
}

#endif
