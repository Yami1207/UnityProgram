#ifndef __IBL_SPECULAR_CGINC__
#define __IBL_SPECULAR_CGINC__

//////////////////////////////////////////////
// Image Based Lighting
// UnityImageBasedLighting.cginc

// 根据粗糙度获取Cubmap的mip级别（unity内置函数）
half PerceptualRoughnessToMipmapLevel(half perceptualRoughness, uint mipMapCount)
{
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
	return perceptualRoughness * mipMapCount;
}

// 环境反射（unity内置函数Unity_GlossyEnvironment）
half3 CalcGlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, UNITY_ARGS_TEXCUBE(tex), half4 hdr)
{
	half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness, 8);
	half4 encodedIrradiance = UNITY_SAMPLE_TEXCUBE_LOD(tex, reflectVector, mip);//texCUBE(environmentMap, half4(reflectVector, mip));
	return half3(encodedIrradiance.rgb * encodedIrradiance.a);
#if !defined(SHADER_API_D3D11) && !defined(SHADER_API_D3D11_9X)
	encodedIrradiance = G2L(encodedIrradiance);
#endif
	return DecodeHDR(encodedIrradiance, hdr);
}

#endif
