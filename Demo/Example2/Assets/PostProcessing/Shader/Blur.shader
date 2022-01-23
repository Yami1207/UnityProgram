Shader "Hidden/PostProcessing/Blur"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
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
			
			#pragma multi_compile _ FIRST_GAUSSIAN_BLUR

			#include "UnityCG.cginc"

			struct Attributes
			{
				float4 positionOS	: POSITION;
				float2 uv			: TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
				half4 texcoord0		: TEXCOORD0;
				half4 texcoord1		: TEXCOORD1;
			};

			inline half4 G2L(half4 color)
			{
#ifdef UNITY_COLORSPACE_GAMMA
				return half4(GammaToLinearSpace(color.rgb), color.a);
#else
				return color;
#endif
			}

			uniform float4 _TexelSize;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = UnityObjectToClipPos(input.positionOS);
				output.texcoord0 = half4(input.uv + _TexelSize.xy, _TexelSize.xy * half2(1.0, -1.0) + input.uv);
				output.texcoord1 = half4(input.uv - _TexelSize.xy, _TexelSize.xy * half2(-1.0, 1.0) + input.uv);
				return output;
			}
			
			half4 frag(Varyings input) : SV_Target
			{
#ifdef FIRST_GAUSSIAN_BLUR
				half4 color = G2L(tex2D(_MainTex, input.texcoord0.xy));
				color += G2L(tex2D(_MainTex, input.texcoord0.zw));
				color += G2L(tex2D(_MainTex, input.texcoord1.xy));
				color += G2L(tex2D(_MainTex, input.texcoord1.zw));
#else
				half4 color = tex2D(_MainTex, input.texcoord0.xy);
				color += tex2D(_MainTex, input.texcoord0.zw);
				color += tex2D(_MainTex, input.texcoord1.xy);
				color += tex2D(_MainTex, input.texcoord1.zw);
#endif
				return 0.25 * color;
			}
			ENDCG
		}
	}
}
