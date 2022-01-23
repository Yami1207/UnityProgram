#ifndef __SHADOW_PASS_CGINC__
#define __SHADOW_PASS_CGINC__

#include "UnityCG.cginc"
#include "../Lib/Macros.cginc"

#define GROUND_HEIGHT	_GlobalShadowHeight + 0.001

//////////////////////////////////////////////
// 材质变量
uniform half4 _MeshShadowColor;

//////////////////////////////////////////////
// 全局变量
uniform half _GlobalShadowHeight;
uniform half _GlobalShadowIntensity;
uniform half3 _XShadowDir;

//////////////////////////////////////////////
// 顶点结构体
struct Attributes
{
	float4 positionOS	: POSITION;
};

//////////////////////////////////////////////
// 片元结构体
struct Varyings
{
	float4 positionCS	: SV_POSITION;
	float4 color		: TEXCOORD0;
};

//////////////////////////////////////////////
// 功能函数
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
// 顶点函数
Varyings vert(Attributes input)
{
	// 投影位置
	float4 positionWS = ShadowProjectPos(input.positionOS);

	// 投影颜色
	float alpha = _GlobalShadowIntensity * _MeshShadowColor.a;
	float4 color = float4(_MeshShadowColor.rgb * alpha, 0.0);

	Varyings output;
	output.positionCS = mul(UNITY_MATRIX_VP, positionWS);
	output.color = color;
	return output;
}

//////////////////////////////////////////////
// 片元函数
half4 frag(Varyings input) : SV_Target
{
	return input.color;
}

#endif
