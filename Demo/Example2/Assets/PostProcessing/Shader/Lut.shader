Shader "Hidden/PostProcessing/Lut"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BloomTex("Texture", 2D) = "black" {}
		_UserLut("Texture", 2D) = "black" {}

		[HideInInspector]_Exposure("", Float) = 0.0
		[HideInInspector]_Contrast("", Float) = 0.0

		[HideInInspector]_MainTex_TexelSize("", Vector) = (0.0, 0.0, 0.0, 0.0)
		[HideInInspector]_FinalBlendFactor("", Vector) = (0.0, 0.0, 0.0, 0.0)
		[HideInInspector]_ConsoleSettings("", Vector) = (0.0, 0.0, 0.0, 0.0)
		[HideInInspector]_UserLut_Params("", Vector) = (0.0, 0.0, 0.0, 0.0)		
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
				float2 uv			: TEXCOORD0;
			};

			//////////////////////////////////////////////
			// 材质属性
			float _Exposure;
			float _Contrast;
			float4 _MainTex_TexelSize;
			float4 _FinalBlendFactor;
			float4 _ConsoleSettings;
			float4 _UserLut_Params;

			//////////////////////////////////////////////
			// 贴图
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BloomTex;
			sampler2D _UserLut;

			//////////////////////////////////////////////
			// 内置函数
			inline float ColorToGrey(float3 color)
			{
				return dot(color, float3(0.22, 0.707, 0.071));
			}

			inline float ColorToGrey(float2 uv)
			{
				float3 color = tex2D(_MainTex, uv).xyz;
				return ColorToGrey(color);
			}

			half3 ApplyLut2d(sampler2D tex, half3 uvw, half3 scaleOffset)
			{
#if 0
				(u_xlat8.xyz = (u_xlat0.xyz * _UserLut_Params.zzz));
				(u_xlat8.x = floor(u_xlat8.x));
				(u_xlat1.xy = (_UserLut_Params.xy * vec2(0.5, 0.5)));
				(u_xlat1.yz = ((u_xlat8.yz * _UserLut_Params.xy) + u_xlat1.xy));
				(u_xlat1.x = ((u_xlat8.x * _UserLut_Params.y) + u_xlat1.y));
				(u_xlat16_3.xyz = texture(_UserLut, u_xlat1.xz).xyz);
				(u_xlat4.x = _UserLut_Params.y);
				(u_xlat4.y = 0.0);
				(u_xlat16.xy = (u_xlat1.xz + u_xlat4.xy));
				(u_xlat16_1.xyz = texture(_UserLut, u_xlat16.xy).xyz);
				(u_xlat0.x = ((u_xlat0.x * _UserLut_Params.z) + (-u_xlat8.x)));
				(u_xlat16_8.xyz = ((-u_xlat16_3.xyz) + u_xlat16_1.xyz));
				(u_xlat0.xyz = ((u_xlat0.xxx * u_xlat16_8.xyz) + u_xlat16_3.xyz));
#endif
				uvw.z *= scaleOffset.z;
				half shift = floor(uvw.z);
				uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
				uvw.x += (float)shift * scaleOffset.y;
				uvw.xyz = lerp(tex2D(tex, uvw.xy).rgb, tex2D(tex, uvw.xy + half2(scaleOffset.y, 0)).rgb, uvw.z - shift);
				return uvw;
			}

			half4 G2L(half4 color)
			{
#ifdef UNITY_COLORSPACE_GAMMA
				return half4(GammaToLinearSpace(color.rgb), color.a);
#else
				return color;
#endif
			}

			half3 G2L(half3 color)
			{
#ifdef UNITY_COLORSPACE_GAMMA
				return GammaToLinearSpace(color);
#else
				return color;
#endif
			}

			half4 L2G(half4 color)
			{
#ifdef UNITY_COLORSPACE_GAMMA
				return half4(LinearToGammaSpace(color.rgb), color.a);
#else
				return color;
#endif
			}

			half3 L2G(half3 color)
			{
#ifdef UNITY_COLORSPACE_GAMMA
				return LinearToGammaSpace(color);
#else
				return color;
#endif
			}
			
			//////////////////////////////////////////////
			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = UnityObjectToClipPos(input.positionOS);
				output.uv = input.uv;
				return output;
			}
			
			float4 frag(Varyings input) : SV_Target
			{
				float4 u_xlat0 = _MainTex_TexelSize.xyxy * float4(-0.5, -0.5, 0.5, 0.5) + input.uv.xyxy;
				float3 u_xlat1 = TRANSFORM_TEX(input.uv, _MainTex).xyy;
				float3 u_xlat8;
				float3 u_xlat16_8;

				// FXAA（FxaaPixelShader）
				float pixelGrey[5];
				pixelGrey[0] = ColorToGrey(u_xlat0.xy);
				pixelGrey[1] = ColorToGrey(u_xlat0.xw);
				pixelGrey[2] = ColorToGrey(u_xlat0.zy) + 0.0026041667;
				pixelGrey[3] = ColorToGrey(u_xlat0.zw);

				float4 mainColor = tex2D(_MainTex, u_xlat1.xy);
				float3 u_xlat2 = mainColor.xyz;
				pixelGrey[4] = ColorToGrey(u_xlat2);

				float minGrey = min(pixelGrey[0], pixelGrey[1]);
				minGrey = min(min(pixelGrey[2], pixelGrey[3]), minGrey);
				float u_xlat3 = minGrey;
				minGrey = min(minGrey, pixelGrey[4]);

				float maxGrey = max(pixelGrey[0], pixelGrey[1]);
				maxGrey = max(max(pixelGrey[2], pixelGrey[3]), maxGrey);
				float3 u_xlat25 = maxGrey;
				maxGrey = max(maxGrey, pixelGrey[4]);

				float greyRange = maxGrey - minGrey;
				float settingRange = max(_ConsoleSettings.z * maxGrey, _ConsoleSettings.w);

				if (greyRange >= settingRange)
				{
					float2 u_xlat11 = _MainTex_TexelSize.xy * _ConsoleSettings.xx;
					float2 u_xlat4 = _MainTex_TexelSize.xy + _MainTex_TexelSize.xy;

					float3 u_xlat16_0;
					u_xlat16_0.x = pixelGrey[1] - pixelGrey[2];
					u_xlat16_8.x = pixelGrey[3] - pixelGrey[0];

					float2 u_xlat5 = float2(u_xlat16_8.x + u_xlat16_0.x, u_xlat16_0.x - u_xlat16_8.x);
					u_xlat0.xy = normalize(u_xlat5).xy;

					float2 uv = u_xlat1.xy - u_xlat0.xy * u_xlat11;
					float3 u_xlat16_5 = tex2D(_MainTex, uv).rgb;
					uv = u_xlat1.xy + u_xlat0.xy * u_xlat11;
					float3 u_xlat16_6 = tex2D(_MainTex, uv).rgb;

					float u_xlat16 = _ConsoleSettings.y * min(abs(u_xlat0.y), abs(u_xlat0.x));
					u_xlat0.xy = u_xlat0.xy / u_xlat16;
					u_xlat0.xy = clamp(u_xlat0.xy, -2.0, 2.0);
					uv = u_xlat1.xy - u_xlat0.xy * u_xlat4;
					float3 u_xlat16_7 = tex2D(_MainTex, uv).rgb;
					uv = u_xlat1.xy + u_xlat0.xy * u_xlat4;
					u_xlat16_0 = tex2D(_MainTex, uv).rgb;

					float3 u_xlat16_4 = u_xlat16_5 + u_xlat16_6;
					u_xlat2 = 0.25 * (u_xlat16_4 + u_xlat16_7 + u_xlat16_0);
					float grey = ColorToGrey(u_xlat2);
					u_xlat8 = 0.5 * u_xlat16_4;
					u_xlat2 = (grey < u_xlat3 || u_xlat25 < grey) ? u_xlat8 : u_xlat2.xyz;
				}
				u_xlat1.xyz = G2L(u_xlat2.xyz);

				// 原图与bloom混合
				float4 bloomColor = tex2D(_BloomTex, input.uv);
				u_xlat0.xyz = _FinalBlendFactor.x * u_xlat1.xyz + _FinalBlendFactor.y * bloomColor.xyz;

				// 颜色校正
				u_xlat0.xyz *= _Exposure;
				u_xlat0.xyz = log2(1.0 - exp2(-u_xlat0.xyz));
				u_xlat0.xyz = exp2((_Contrast + 0.01) * u_xlat0.xyz);

				// G2L
				float3 color = saturate(u_xlat0.xyz);
				float3 colorGraded = ApplyLut2d(_UserLut, L2G(color), _UserLut_Params.xyz);
				colorGraded = G2L(colorGraded);

				color = lerp(color, colorGraded, _UserLut_Params.w);
				return L2G(float4(color, mainColor.a));
			}
			ENDCG
		}
	}
}
