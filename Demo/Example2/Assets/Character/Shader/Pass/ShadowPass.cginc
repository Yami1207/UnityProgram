#ifndef __SHADOW_PASS_CGINC__
#define __SHADOW_PASS_CGINC__

#include "UnityCG.cginc"
#include "../Lib/Macros.cginc"

#define GROUND_HEIGHT	_GlobalShadowHeight + 0.001

//////////////////////////////////////////////
// ���ʱ���
uniform half4 _MeshShadowColor;

//////////////////////////////////////////////
// ȫ�ֱ���
uniform half _GlobalShadowHeight;
uniform half _GlobalShadowIntensity;
uniform half3 _XShadowDir;

//////////////////////////////////////////////
// ����ṹ��
struct Attributes
{
	float4 positionOS	: POSITION;
};

//////////////////////////////////////////////
// ƬԪ�ṹ��
struct Varyings
{
	float4 positionCS	: SV_POSITION;
	float4 color		: TEXCOORD0;
};

//////////////////////////////////////////////
// ���ܺ���
float4 ShadowProjectPos(float4 positionOS)
{
	float height = _GlobalShadowHeight;
	float3 positionWS = mul(unity_ObjectToWorld, positionOS).xyz;
	float3 lightDir = normalize(UnityWorldSpaceLightDir(positionWS));

	float posY = height - positionWS.y;
	float rate = posY / lightDir.y;
	float posX = lightDir.x* rate + positionWS.x;
	float posZ = lightDir.z* rate + positionWS.z;
	return float4(posX, height, posZ, 1.0);
}

//////////////////////////////////////////////
// ���㺯��
Varyings vert(Attributes input)
{
	// ͶӰλ��
	float4 positionWS = ShadowProjectPos(input.positionOS);

	// ͶӰ��ɫ
	float alpha = _GlobalShadowIntensity * _MeshShadowColor.a;
	float4 color = float4(_MeshShadowColor.rgb * alpha, 0.0);

	Varyings output;
	output.positionCS = mul(UNITY_MATRIX_VP, positionWS);
	output.color = color;
	return output;
}

//////////////////////////////////////////////
// ƬԪ����
half4 frag(Varyings input) : SV_Target
{
	return input.color;
}

#endif
