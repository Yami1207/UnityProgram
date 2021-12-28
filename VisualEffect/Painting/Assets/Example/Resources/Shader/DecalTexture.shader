Shader "Paint/Example/Decal Texture"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
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
				float4 screenUV		: TEXCOORD0;
				float3 rayVS		: TEXCOORD1;
			};

            sampler2D _MainTex;
			sampler2D_float _CameraDepthTexture;

			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;
				output.positionCS = UnityObjectToClipPos(input.positionOS);
				output.screenUV = ComputeScreenPos(output.positionCS);
				output.rayVS = UnityObjectToViewPos(float4(input.positionOS.xyz, 1)).xyz * float3(-1, -1, 1);
				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				// 获取当前像素的深度值
				float2 uv = input.screenUV.xy / input.screenUV.w;
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				depth = Linear01Depth(depth);

				// 通过深度值计算出场景交点(视角坐标系)
				input.rayVS = input.rayVS * (_ProjectionParams.z / input.rayVS.z);
				float4 positionVS = float4(input.rayVS * depth, 1);

				// 视角坐标系转到物体坐标系
				float3 positionWS = mul(unity_CameraToWorld, positionVS).xyz;
				float3 positionOS = mul(unity_WorldToObject, float4(positionWS, 1)).xyz;

				// 裁剪边境像素
				clip(float3(0.5, 0.5, 0.5) - abs(positionOS.xyz));

				// 由于坐标是-0.5到0.5，需要加0.5
				half4 color = tex2D(_MainTex, positionOS.xy + 0.5);
				return color;
			}
            ENDCG
        }
    }
}
