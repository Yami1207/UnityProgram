#ifndef __STENCIL_MASK_PASS_CGINC__
#define __STENCIL_MASK_PASS_CGINC__

struct Attributes
{
	float4 positionOS	: POSITION;
	float2 uv			: TEXCOORD0;
};

struct Varyings
{
	float4 positionCS	: SV_POSITION;
	float2 uv           : TEXCOORD0;
};

uniform sampler2D _StencilMaskTex;

Varyings vert(Attributes input)
{
	Varyings output;
	output.positionCS = UnityObjectToClipPos(input.positionOS);
	output.uv = input.uv;
	return output;
}

half4 frag(Varyings input) : SV_Target
{
	half4 mask = tex2D(_StencilMaskTex, input.uv);
	clip(mask.r - 0.5);
	return mask;
}

#endif
