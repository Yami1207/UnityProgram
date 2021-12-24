Shader "Paint/Example/TextureProj"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RayNormal("_RayNormal", Vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		//ZTest Always
		ZWrite Off
		ColorMask RGB
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			//struct appdata
			//{
			//	float4 vertex : POSITION;
			//};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			
			float4 _RayNormal;
			float4x4 unity_Projector;
			
			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = mul(unity_Projector, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				// 裁剪不在[0,1]范围的像素
				fixed3 uv = i.uv.xyz;
				uv.z = (uv.z + 1.0) * 0.5;
				clip(1 - abs(uv + floor(uv)));

				fixed4 color = tex2Dproj(_MainTex, UNITY_PROJ_COORD(i.uv));
				
				// 不显示背面
				fixed isPositive = step(0.01, max(0, dot(i.normal, -_RayNormal.xyz)));
				color.a *= isPositive;

				return color;
			}
			ENDCG
		}
	}
}
