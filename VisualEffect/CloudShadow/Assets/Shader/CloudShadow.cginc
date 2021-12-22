#ifndef __CLOUD_SHADOW_CGINC__
#define __CLOUD_SHADOW_CGINC__

#if ENABLE_CLOUD_SHADOW

// 云影UV平铺值
uniform float2 g_CloudShadowTile;

// 云影速度
uniform float3 g_CloudShadowVelocity;

// 云影颜色值
uniform half4 g_CloudShadowColor;

// 云影纹理
uniform sampler2D g_CloudShadowTexture;

// 计算云影值
inline half3 MixCloudShadow(half3 color, float3 positionWS)
{
	// 根据像素世界坐标计算UV值
	float2 uv = positionWS.xz * g_CloudShadowTile.xy - _Time.y * g_CloudShadowVelocity.xz;

	// 云影厚度
	half thickness = tex2D(g_CloudShadowTexture, uv).r * g_CloudShadowColor.a;

	// 混合当前像素和云影
	return color * lerp(1.0, g_CloudShadowColor.rgb, thickness);
}

#define MIX_CLOUD_SHADOW(color, positionWS)	color.rgb = MixCloudShadow(color, positionWS)
#else
#define MIX_CLOUD_SHADOW(color, positionWS) 
#endif

#endif
