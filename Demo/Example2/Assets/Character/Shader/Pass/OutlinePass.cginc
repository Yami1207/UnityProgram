#ifndef __OUTLINE_PASS_CGINC__
#define __OUTLINE_PASS_CGINC__

#include "UnityCG.cginc"

struct Attributes
{
	float4 positionOS	: POSITION;
	float3 normal		: TEXCOORD3;

#if defined(USE_TBN)
	float3 normalOS		: NORMAL;
	float4 tangentOS    : TANGENT;
#endif
	
#if defined(USE_VERTEX_COLOR)
	float4 color		: COLOR0;
#endif
};

struct Varyings
{
	float4 positionCS : SV_POSITION;
#if defined(USE_VERTEX_COLOR)
	float4 color : TEXCOORD0;
#endif
};

uniform half _XOutlineZMaxOffset;
uniform half _XOutlineDitanceScale;

uniform half _XOutlineZOffset;
uniform half _XCharOutlineWidth;

uniform half _XOutlineBrightness;
uniform half3 _XGlobalCharOutlineColor;

uniform half _OutlineBloom;
uniform half4 _OutlineColor;

uniform half4 _LinearFogColor;
uniform half4 _LinearFogParams;

Varyings vert(Attributes input)
{
	float3 normal = 2.0 * input.normal.xyz - 1.0;
#if defined(USE_TBN)
	float3 bitangentOS = cross(input.normalOS, input.tangentOS);
	bitangentOS.xyz *= input.tangentOS.w;
	normal = normal.x * input.tangentOS.xyz + normal.y * bitangentOS + normal.z * input.normalOS;
#endif
	normal = normalize(mul((float3x3)UNITY_MATRIX_V, mul((float3x3)unity_ObjectToWorld, -normal.xyz)));
	normal.z = 0.001;
	normal.xy = normalize(normal).xy;

	float3 positionVS = mul(UNITY_MATRIX_MV, input.positionOS);
	float3 u_xlat2 = normalize(positionVS);

	float u_xlat6 = positionVS.z / unity_CameraProjection[1].y;
	float outlineWidth = _XCharOutlineWidth;

#if defined(USE_OFFSET_SCALE)
	outlineWidth *= _XOutlineDitanceScale;

	u_xlat2 *= _XOutlineZMaxOffset;
	u_xlat2 *= _XOutlineDitanceScale;
	u_xlat2 = 0.5 * u_xlat2 + positionVS;

	u_xlat6 = u_xlat6 / _XOutlineDitanceScale;
	u_xlat6 = sqrt(-u_xlat6);
	u_xlat6 = u_xlat6 * outlineWidth * 0.018;
#else
	u_xlat2 = 0.0015 * u_xlat2 + positionVS;

	u_xlat6 = 66.666672 * u_xlat6;
	u_xlat6 = sqrt(-u_xlat6);
	u_xlat6 = u_xlat6 * outlineWidth * 0.00027;
#endif

#if defined(USE_VERTEX_COLOR)
	u_xlat6 = input.color.z * u_xlat6;
#endif

	positionVS.xy = normal.xy * u_xlat6 + u_xlat2.xy;
	positionVS.z = _XOutlineZOffset + u_xlat2.z;

	Varyings output;
	output.positionCS = mul(UNITY_MATRIX_P, float4(positionVS, 1));
#if defined(USE_VERTEX_COLOR)
	output.color = input.color;
#endif
	return output;
}

half4 frag(Varyings input) : SV_Target
{
#if defined(USE_VERTEX_COLOR)
	clip(input.color.b - 0.1);
#endif
	
	half fogCoord = max(input.positionCS.z, 0.0);
	fogCoord = saturate(fogCoord * _LinearFogParams.x + _LinearFogParams.y);

	half3 color = _XOutlineBrightness * _OutlineColor.rgb * _XGlobalCharOutlineColor.rgb;
#if 0
	color = lerp(_LinearFogColor, color, fogCoord);
	half alpha = lerp(_LinearFogColor.a, _OutlineBloom, fogCoord);
#else
	half alpha = _OutlineBloom;
#endif

	return half4(color, alpha);
}

#endif
