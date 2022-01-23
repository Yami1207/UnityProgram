Shader "Hidden/PostProcessing/Filter"
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

			uniform half _FilterScaler;
			uniform half _FilterThreshold;

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
				half4 color = tex2D(_MainTex, input.uv.xy);
				color.rgb = _FilterScaler * (color.rgb - _FilterThreshold.xxx) * color.a;
				color.rgb = max(color.rgb, half3(0.0, 0.0, 0.0));
				return color;
			}
			ENDCG
		}
	}
}
