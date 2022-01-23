Shader "Hidden/PostProcessing/Blur128"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct Attributes
			{
				float4 positionOS	: POSITION;
				float2 uv			: TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
				half2 uv			: TEXCOORD0;
			};

			uniform half2 _BlurDir;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = UnityObjectToClipPos(input.positionOS);
				output.uv = input.uv;
				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				const half2 BlurParams[8] = {
					half2(-0.047556002, 0.000394),
					half2(-0.032535002, 0.015949),
					half2(-0.017878, 0.163609),
					half2(-0.003554, 0.43994),
					half2(0.010686, 0.31658),
					half2(0.025157999, 0.060512),
					half2(0.040004998, 0.0029819999),
					half2(0.054687999, 3.4000001e-05)
				};

				half4 color = half4(0, 0, 0, 0);
				for (int i = 0; i < 8; ++i)
				{
					half2 uv = BlurParams[i].x * _BlurDir.xy + input.uv.xy;
					color += BlurParams[i].y * tex2D(_MainTex, uv);
				}
				return color;
			}
			ENDCG
		}
	}
}
