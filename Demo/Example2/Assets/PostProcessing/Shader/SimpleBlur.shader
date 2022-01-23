Shader "Hidden/PostProcessing/SimpleBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100
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
				const half2 BlurParams[11] = {
					half2(-0.14337599, 0.000271),
					half2(-0.112941, 0.0038930001),
					half2(-0.082662001, 0.029742001),
					half2(-0.052524, 0.12125),
					half2(-0.02249, 0.26444501),
					half2(0.007495, 0.30904999),
					half2(0.037498001, 0.193602),
					half2(0.067578003, 0.064944997),
					half2(0.097782999, 0.01164),
					half2(0.128139, 0.001112),
					half2(0.015625, 4.8000002e-05)
				};

				half4 color = half4(0, 0, 0, 0);
				for (int i = 0; i < 11; ++i)
				{
					half2 uv = BlurParams[i].x * _BlurDir.xy + input.uv.xy;
					color += BlurParams[i].y * tex2D(_MainTex, uv);
				}

				//half4 uv = _BlurDir.xyxy * half4(-0.14337599, -0.14337599, -0.112941, -0.112941) + input.uv.xyxy;
				//half4 color = 0.000271 * tex2D(_MainTex, uv.xy);
				//color += 0.0038930001 * tex2D(_MainTex, uv.zw);

				//uv = _BlurDir.xyxy * half4(-0.082662001, -0.082662001, -0.052524, -0.052524) + input.uv.xyxy;
				//color += 0.029742001 * tex2D(_MainTex, uv.xy);
				//color += 0.12125 * tex2D(_MainTex, uv.zw);

				//uv = _BlurDir.xyxy * half4(-0.02249, -0.02249, 0.007495, 0.007495) + input.uv.xyxy;
				//color += 0.26444501 * tex2D(_MainTex, uv.xy);
				//color += 0.30904999 * tex2D(_MainTex, uv.zw);

				//uv = _BlurDir.xyxy * half4(0.037498001, 0.037498001, 0.067578003, 0.067578003) + input.uv.xyxy;
				//color += 0.193602 * tex2D(_MainTex, uv.xy);
				//color += 0.064944997 * tex2D(_MainTex, uv.zw);

				//uv = _BlurDir.xyxy * half4(0.097782999, 0.097782999, 0.128139, 0.128139) + input.uv.xyxy;
				//color += 0.011641 * tex2D(_MainTex, uv.xy);
				//color += 0.001112 * tex2D(_MainTex, uv.zw);

				//uv.xy = 0.015625 * _BlurDir.xy + input.uv.xy;
				//color += 4.8000002e-05 * tex2D(_MainTex, uv.xy);

				return color;
			}
			ENDCG
		}
	}
}
