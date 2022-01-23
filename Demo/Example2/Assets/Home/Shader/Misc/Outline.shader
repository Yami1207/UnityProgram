Shader "Example/Home/Outline"
{
	Properties
	{
		_OutlineSize("Size", Range(0.0, 0.002)) = 0.001
		_OutlineBloom("Outline Bloom", Float) = 0.1
		[Linear]_OutlineColor("Outline Color", Vector) = (0.09441, 0.04062, 0.04062, 1.00)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry+210" }
		LOD 100
		Cull front
		Blend off
		ZWrite On
		ZTest LEqual

		Pass
		{
			Name "Outline"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct Attributes
			{
				float4 positionOS	: POSITION;
				float3 normalOS		: NORMAL;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
			};

			uniform half _OutlineSize;
			uniform half _OutlineBloom;
			uniform half3 _OutlineColor;
			
			Varyings vert(Attributes input)
			{
				float4 positionCS = UnityObjectToClipPos(input.positionOS);
				float3 normalWS = UnityObjectToWorldNormal(input.normalOS);
				float3 normalCS = mul((float3x3)UNITY_MATRIX_VP, normalWS);
				float2 extrudeDir = normalize(normalCS.xy) * _OutlineSize * positionCS.w * 2.0;
				extrudeDir.x *= _ScreenParams.y / _ScreenParams.x;
				positionCS.xy += extrudeDir;

				Varyings output = (Varyings)0;
				output.positionCS = positionCS;
				return output;
			}
			
			half4 frag(Varyings input) : SV_Target
			{
				return half4(_OutlineColor, _OutlineBloom);
			}
			ENDCG
		}
	}
}
