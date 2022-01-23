#ifndef __BLOOM_PASS_CGINC__
#define __BLOOM_PASS_CGINC__

#include "UnityCG.cginc"

struct Attributes
{
	float4 positionOS	: POSITION;
};

struct Varyings
{
	float4 positionCS	: SV_POSITION;
};

//////////////////////////////////////////////
// ≤ƒ÷ ±‰¡ø
uniform half _BloomFactor;

Varyings vert(Attributes input)
{
	Varyings output;
	output.positionCS = UnityObjectToClipPos(input.positionOS);
	return output;
}

half4 frag(Varyings input) : SV_Target
{
	return half4(0.0, 0.0, 0.0, _BloomFactor);
}

#endif
