#ifndef __SHADOWS_CGINC__
#define __SHADOWS_CGINC__

inline float4 GetShadowCoord(float3 positionWS)
{
	return mul(_XShadowWorldToProj, float4(positionWS, 1.0));
}

float GetShadowBias(float3 lightDir, float3 normalWS, float baseBias, float maxBias)
{
	float cosVal = saturate(dot(normalWS, lightDir));
	float sinVal = sqrt(1 - cosVal * cosVal);
	float tanVal = sinVal / cosVal;
	float bias = baseBias + clamp(tanVal, 0, maxBias);
	return bias;
}

half SampleShadowMap(float4 shadowCoord, float3 normalWS)
{
	shadowCoord.xyz = shadowCoord.xyz / shadowCoord.w;
	shadowCoord.xy = 0.5 * shadowCoord.xy + 0.5;
	if (shadowCoord.x > 1.0 || shadowCoord.x < 0.0 || shadowCoord.y > 1.0 || shadowCoord.y < 0.0)
		return 0.0;

	float depth = DecodeFloatRGBA(tex2D(_XShadowTexture, shadowCoord.xy));
	float bias = GetShadowBias(_XWorldSpaceShadowLightDir, normalWS, _XShadowNormalBias, _XShadowNormalBias + 0.01);
	return step(shadowCoord.z + bias, depth);
}

#endif
