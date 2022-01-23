Shader "Hidden/PostProcessing/MixBloom"
{
	Properties
	{
		_BloomTex0("", 2D) = "white" {}
		_BloomTex1("", 2D) = "white" {}
		_BloomTex2("", 2D) = "white" {}
		_BloomTex3("", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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

			uniform half4 _BloomCombineCoeff;

			sampler2D _BloomTex0;
			sampler2D _BloomTex1;
			sampler2D _BloomTex2;
			sampler2D _BloomTex3;
			
			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = UnityObjectToClipPos(input.positionOS);
				output.uv = input.uv;
				return output;
			}
			
			half4 frag(Varyings input) : SV_Target
			{
				half4 color = _BloomCombineCoeff.x * tex2D(_BloomTex0, input.uv);
				color += _BloomCombineCoeff.y * tex2D(_BloomTex1, input.uv);
				color += _BloomCombineCoeff.z * tex2D(_BloomTex2, input.uv);
				color += _BloomCombineCoeff.w * tex2D(_BloomTex3, input.uv);
				return color;
			}
			ENDCG
		}
	}
}
