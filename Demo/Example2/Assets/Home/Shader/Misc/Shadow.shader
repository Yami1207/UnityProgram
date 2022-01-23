Shader "Example/Home/Shadow"
{
	Properties
	{
		_ShadowVolumeMinHeight("Shadow Volume Min Height", Float) = -1.14
		_ShadowVolumeSource("Shadow Volume Source", Vector) = (0.29093, 0.91587, -0.27666, 0.0)
		_ShadowVolumeColor("Shadow Volume Color", Color) = (0.0, 0.0, 0.0, 1.0)
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+100" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off
		ZTest LEqual

		Stencil
		{
			Ref 0
			Comp equal
			Pass incrWrap
			Fail keep
			ZFail keep
		}

		Pass
		{
			Name "Shadow"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct Attributes
			{
				float4 positionOS	: POSITION;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
			};

			uniform float _ShadowVolumeMinHeight;
			uniform float4 _ShadowVolumeSource;
			uniform half4 _ShadowVolumeColor;
			
			Varyings vert(Attributes input)
			{
				float3 positionWS = mul(unity_ObjectToWorld, input.positionOS).xyz;
				
				// 投影方向
				float3 shadowDir = normalize(_ShadowVolumeSource.xyz);
				shadowDir = normalize(shadowDir);

				// 计算出投影世界坐标
				float height = _ShadowVolumeMinHeight;
				float3 shadowPos = float3(0, height, 0);
				shadowPos.xz = positionWS.xz - shadowDir.xz * (positionWS.y / (shadowDir.y + height));

				// 不处理低于投影面高度的顶点
				shadowPos = lerp(shadowPos, positionWS, step(positionWS.y - height, 0));

				Varyings output = (Varyings)0;
				output.positionCS = UnityWorldToClipPos(shadowPos);
				return output;
			}
			
			half4 frag(Varyings input) : SV_Target
			{
				return _ShadowVolumeColor;
			}
			ENDCG
		}
	}
}
