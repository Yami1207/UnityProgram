#ifndef __CLOUD_SHADOW_CGINC__
#define __CLOUD_SHADOW_CGINC__

#if ENABLE_CLOUD_SHADOW

// ��ӰUVƽ��ֵ
uniform float2 g_CloudShadowTile;

// ��Ӱ�ٶ�
uniform float3 g_CloudShadowVelocity;

// ��Ӱ��ɫֵ
uniform half4 g_CloudShadowColor;

// ��Ӱ����
uniform sampler2D g_CloudShadowTexture;

// ������Ӱֵ
inline half3 MixCloudShadow(half3 color, float3 positionWS)
{
	// �������������������UVֵ
	float2 uv = positionWS.xz * g_CloudShadowTile.xy - _Time.y * g_CloudShadowVelocity.xz;

	// ��Ӱ���
	half thickness = tex2D(g_CloudShadowTexture, uv).r * g_CloudShadowColor.a;

	// ��ϵ�ǰ���غ���Ӱ
	return color * lerp(1.0, g_CloudShadowColor.rgb, thickness);
}

#define MIX_CLOUD_SHADOW(color, positionWS)	color.rgb = MixCloudShadow(color, positionWS)
#else
#define MIX_CLOUD_SHADOW(color, positionWS) 
#endif

#endif
