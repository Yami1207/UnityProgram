Shader "Hidden/PostProcessing/Blur256"
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
				const half2 BlurParams[5] = {
					half2(-0.011912, 0.0086089997),
					half2(-0.004764, 0.30802599),
					half2(0.001547, 0.60708803),
					half2(0.0082339998, 0.075851999),
					half2(0.015625, 0.000425)
				};

				half4 color = half4(0, 0, 0, 0);
				for (int i = 0; i < 5; ++i)
				{
					half2 uv = BlurParams[i].x * _BlurDir.xy + input.uv.xy;
					color += BlurParams[i].y * tex2D(_MainTex, uv);
				}

				//half4 uv = _BlurDir.xyxy * half4(-0.011912, -0.011912, -0.004764, -0.004764) + input.uv.xyxy;
				//half4 color0 = 0.0086089997 * tex2D(_MainTex, uv.xy);
				//half4 color1 = 0.30802599 * tex2D(_MainTex, uv.zw);
				//
				//uv = _BlurDir.xyxy * half4(0.001547, 0.001547, 0.0082339998, 0.0082339998) + input.uv.xyxy;
				//half4 color2 = 0.60708803 * tex2D(_MainTex, uv.xy);
				//half4 color3 = 0.075851999 * tex2D(_MainTex, uv.zw);

				//uv.xy = 0.015625 * _BlurDir.xy + input.uv.xy;
				//half4 color4 = 00001 * tex2D(_MainTex, uv.zw);

				//return color0 + color1 + color2 + color3 + color4;
				return color;
			}
			ENDCG
		}
	}
}
