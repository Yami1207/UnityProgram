#ifndef __COMMON_CGINC__
#define __COMMON_CGINC__

#include "Macros.cginc"

float3 SafeNormalize(float3 inVec)
{
	float dp3 = max(FLT_MIN, dot(inVec, inVec));
	return inVec * rsqrt(dp3);
}

//half3 PositivePow(half3 base, half3 power)
//{
//	return pow(abs(base), power);
//}
//
//half3 SRGBToLinear(half3 c)
//{
//	half3 linearRGBLo = c / 12.92;
//	half3 linearRGBHi = PositivePow((c + 0.055) / 1.055, half3(2.4, 2.4, 2.4));
//	half3 linearRGB = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
//	return linearRGB;
//}
//
//half4 SRGBToLinear(half4 c)
//{
//	return half4(SRGBToLinear(c.rgb), c.a);
//}
//
//half3 LinearToSRGB(half3 c)
//{
//	half3 sRGBLo = c * 12.92;
//	half3 sRGBHi = (PositivePow(c, half3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
//	half3 sRGB = (c <= 0.0031308) ? sRGBLo : sRGBHi;
//	return sRGB;
//}
//
//half4 LinearToSRGB(half4 c)
//{
//	return half4(LinearToSRGB(c.rgb), c.a);
//}
//

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
