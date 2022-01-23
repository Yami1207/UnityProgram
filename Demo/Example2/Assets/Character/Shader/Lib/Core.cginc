#ifndef __CORE_CGINC__
#define __CORE_CGINC__

#include "UnityCG.cginc"

#include "Macros.cginc"
#include "Input.cginc"
#include "Common.cginc"
#include "Lighting.cginc"
#include "Shadows.cginc"

struct VertexPositionInputs
{
	float3 positionWS; // World space position
	float3 positionVS; // View space position
	float4 positionCS; // Homogeneous clip space position
};

struct VertexNormalInputs
{
	float3 tangentWS;
	float3 bitangentWS;
	float3 normalWS;
};

VertexPositionInputs GetVertexPositionInputs(float4 positionOS)
{
	VertexPositionInputs input;
	input.positionWS = mul(unity_ObjectToWorld, positionOS).xyz;
	input.positionVS = UnityObjectToViewPos(positionOS);
	input.positionCS = UnityObjectToClipPos(positionOS);
	return input;
}

VertexNormalInputs GetVertexNormalInputs(float3 normalOS, float4 tangentOS)
{
	VertexNormalInputs tbn;
	tbn.normalWS = UnityObjectToWorldNormal(normalOS);
	tbn.tangentWS = UnityObjectToWorldDir(tangentOS.xyz);

	half sign = tangentOS.w * unity_WorldTransformParams.w;
	tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;

	return tbn;
}

#endif
