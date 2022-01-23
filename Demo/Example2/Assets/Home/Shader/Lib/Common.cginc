#ifndef __COMMON_CGINC__
#define __COMMON_CGINC__

float3 SafeNormalize(float3 inVec)
{
	float dp3 = max(FLT_MIN, dot(inVec, inVec));
	return inVec * rsqrt(dp3);
}

inline half4 G2L(half4 color)
{
#ifdef UNITY_COLORSPACE_GAMMA
	return half4(GammaToLinearSpace(color.rgb), color.a);
	//return half4(SRGBToLinear(color.rgb), color.a);
#else
	return color;
#endif
}

inline half3 G2L(half3 color)
{
#ifdef UNITY_COLORSPACE_GAMMA
	return GammaToLinearSpace(color);
	//return half4(SRGBToLinear(color.rgb), color.a);
#else
	return color;
#endif
}

inline half4 L2G(half4 color)
{
#ifdef UNITY_COLORSPACE_GAMMA
	return half4(LinearToGammaSpace(color.rgb), color.a);
	//return half4(LinearToSRGB(color.rgb), color.a);
#else
	return color;
#endif
}

inline half3 L2G(half3 color)
{
#ifdef UNITY_COLORSPACE_GAMMA
	return LinearToGammaSpace(color);
#else
	return color;
#endif
}

#endif
