Shader "Hidden/Example/DepthOnly"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			struct Attributes
			{
				float4 positionOS : POSITION;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 depth : TEXCOORD0;
			};

			Varyings vert(Attributes input)
			{
				float4 positionCS = UnityObjectToClipPos(input.positionOS);

				Varyings output;
				output.positionCS = positionCS;
				output.depth = positionCS.zw;
				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				float depth = input.depth.x / input.depth.y;
				return EncodeFloatRGBA(depth);
			}
            ENDCG
        }
    }
}
