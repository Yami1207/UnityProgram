Shader "Example/Texture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

			#define ENABLE_CLOUD_SHADOW	1

            #include "UnityCG.cginc"
			#include "../../Shader/CloudShadow.cginc"

            struct Attributes
            {
				float4 positionOS	: POSITION;
                float2 texcoord		: TEXCOORD0;
            };

            struct Varyings
            {
				float4 positionCS	: SV_POSITION;
				float2 texcoord		: TEXCOORD0;
				float3 positionWS	: TEXCOORD1;
                UNITY_FOG_COORDS(3)
            };

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			Varyings vert(Attributes input)
            {
				Varyings output = (Varyings)0;
				output.positionCS = UnityObjectToClipPos(input.positionOS);
				output.positionWS = mul(unity_ObjectToWorld, input.positionOS).xyz;
				output.texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(output, output.positionCS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
				half4 color = tex2D(_MainTex, input.texcoord);
				MIX_CLOUD_SHADOW(color, input.positionWS);
                UNITY_APPLY_FOG(input.fogCoord, color);
                return color;
            }
            ENDCG
        }
    }
}
