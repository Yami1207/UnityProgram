Shader "Example/Sky"
{
	Properties
	{
		_XSky4PI("Sky 4 PI", Vector) = (0.13245, 0.23809, 0.4937, 0.02513)
		_XSkyLocalSunDirection("Sky Local Sun Direction", Vector) = (0.01243, 0.70215, -0.71192, 0)
		[Linear]_XSkyMieColor("Sky Mie Color", Vector) = (0.53893, 0.81175, 0.82353, 0)
		_XSkyRadius("Sky Radius", Vector) = (1.00, 1.00, 1.025, 1.05062)
		[Linear]_XSkyRayleighColor("Sky Ray leigh Color", Vector) = (0.81142, 0.90335, 0.98529, 0)
		_XSkyScale("Sky Scale", Vector) = (40.00004, 0.25, 160.00015, 0.0001)
		_XSkySun("Sky Sun", Vector) = (0.42161, 0.75786, 1.5715, 0.08)
		[Linear]_XSkySunSkyColor("Sky Sun Sky Color", Vector) = (0.97647, 0.61961, 0.42353, 0)

		[Linear]_XSceneDarkColor("Scene Dark Color", Vector) = (0.00, 0.00, 0.00, 0.00)
		_XSceneGray("Scene Gray", Float) = 0.0
		_XSkyBloom("Sky Bloom", Float) = 0.0
		_XSkyBrightness("Sky Brightness", Float) = 1.0
		_XSkyContrast("Sky Contrast", Float) = 2.0
		[Linear]_XSkyFogColor("Sky Fog Color", Vector) = (1.00, 1.00, 1.00, 0.00)
		_XSkyFogginess("Sky Fogginess", Float) = 0.0
		[Linear]_XSkyGroundColor("Sky Ground Color", Vector) = (0.01424, 0.45499, 0.88971, 0.00)
		_XSkyLocalMoonDirection("Sky Local Moon Direction", Vector) = (-0.06781, -0.99357, -0.09065, 0.00)
		_XSkyLocalSunDirection("Sky Local Sun Direction", Vector) = (0.01243, 0.70215, -0.71192, 0.00)
		_XSkyMie("Sky Mie", Vector) = (0.13227, 1.7569, -1.74, 0.00)
		[Linear]_XSkyMoonHaloColor("Sky Moon Halo Color", Vector) = (1.00, 1.00, 1.00, 0.00)
		_XSkyMoonHaloPower("Sky Moon Halo Power", Float) = 50.0
		[Linear]_XSkyMoonSkyColor("Sky Moon Sky Color", Vector) = (0.63354, 0.76944, 0.92647, 0.00)
		[Linear]_XSkyTopColor("Sky Top Color", Vector) = (0.69853, 0.83168, 1.00, 0.00)
		_XSkyTopColorBlend("Sky Top Color Blend", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Blend one zero

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "../Lib/Common.cginc"

			struct Attributes
			{
				float4 positionOS : POSITION;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				half3 mieColor : TEXCOORD1;
				half3 rayleighColor : TEXCOORD2;
			};

			//////////////////////////////////////////////
			// 材质输入
			uniform float3 _XSkyMieColor;
			uniform float3 _XSkyRayleighColor;
			uniform float3 _XSkySunSkyColor;
			uniform float3 _XSkyLocalSunDirection;
			uniform float4 _XSkySun;
			uniform float4 _XSky4PI;
			uniform float4 _XSkyRadius;
			uniform float4 _XSkyScale;

			uniform float4 _XSceneDarkColor;
			uniform float _XSceneGray;
			uniform float _XSkyBloom;
			uniform float _XSkyBrightness;
			uniform float _XSkyContrast;
			uniform float4 _XSkyFogColor;
			uniform float _XSkyFogginess;
			uniform float4 _XSkyGroundColor;
			uniform float3 _XSkyLocalMoonDirection;
			uniform float3 _XSkyMie;
			uniform float4 _XSkyMoonHaloColor;
			uniform float _XSkyMoonHaloPower;
			uniform float4 _XSkyMoonSkyColor;
			uniform float4 _XSkyTopColor;
			uniform float _XSkyTopColorBlend;
			
			//////////////////////////////////////////////
			Varyings vert(Attributes input)
			{
				float4 positionCS = UnityObjectToClipPos(input.positionOS);
				float3 normalWS = normalize(input.positionOS);

				float4 u_xlat0 = normalWS.xyzy;
				u_xlat0.w = max(u_xlat0.w, 0.0);
				float u_xlat3 = sqrt(dot(u_xlat0.xzw, u_xlat0.xzw));
				u_xlat0.xyz = u_xlat0.xwz / u_xlat3;

				float u_xlat9 = u_xlat0.y * u_xlat0.y * _XSkyRadius.y;
				u_xlat9 = u_xlat9 + _XSkyRadius.w - _XSkyRadius.y;
				u_xlat9 = sqrt(u_xlat9);
				u_xlat9 = u_xlat9 - _XSkyRadius.x * u_xlat0.y;

				float3 u_xlat1 = u_xlat9 * u_xlat0;
				u_xlat9 = u_xlat9 * _XSkyScale.x;

				float3 u_xlat2 = float3(0.0, _XSkyRadius.x + _XSkyScale.w, 0.0);
				u_xlat1 = 0.5 * u_xlat1 + u_xlat2;

				u_xlat0.x = dot(u_xlat0, u_xlat1);

				u_xlat3 = 1.0 - u_xlat0.y;

				float u_xlat6 = dot(u_xlat1, u_xlat1);
				u_xlat6 = max(sqrt(u_xlat6), 1.0);
				float u_xlat4 = 1.0 / u_xlat6;
				u_xlat6 = _XSkyRadius.x - u_xlat6;
				u_xlat6 = u_xlat6 * _XSkyScale.z * 1.442695;
				u_xlat6 = exp2(u_xlat6);

				u_xlat1.x = dot(_XSkyLocalSunDirection.xyz, u_xlat1);
				u_xlat0.x = 1.0 - u_xlat0.x * u_xlat4;
				u_xlat1.x = 1.0 - u_xlat1.x * u_xlat4;

				u_xlat4 = u_xlat0.x * 5.25 - 6.8;
				u_xlat4 = u_xlat0.x * u_xlat4 + 3.83;
				u_xlat4 = u_xlat0.x * u_xlat4 + 0.46;
				u_xlat0.x = u_xlat0.x * u_xlat4 - 0.00287;
				u_xlat0.x = u_xlat0.x * 1.442695;
				u_xlat0.x = exp2(u_xlat0.x);
				u_xlat0.x = u_xlat0.x * 0.25;

				u_xlat4 = u_xlat1.x * 5.25 - 6.8;
				u_xlat4 = u_xlat1.x * u_xlat4 + 3.83;
				u_xlat4 = u_xlat1.x * u_xlat4 + 0.46;
				u_xlat1.x = u_xlat1.x * u_xlat4 - 0.00287;
				u_xlat1.x = u_xlat1.x * 1.442695;
				u_xlat1.x = exp2(u_xlat1.x);
				u_xlat0.x = u_xlat1.x * 0.25 - u_xlat0.x;
				u_xlat0.x = u_xlat0.x * u_xlat6;
				u_xlat6 = u_xlat9 * u_xlat6;

				u_xlat9 = u_xlat3 * 5.25 - 6.8;
				u_xlat9 = u_xlat3 * u_xlat9 + 3.83;
				u_xlat9 = u_xlat3 * u_xlat9 + 0.46;
				u_xlat3 = u_xlat3 * u_xlat9 - 0.00287;
				u_xlat3 = u_xlat3 * 1.442695;
				u_xlat3 = exp2(u_xlat3);
				u_xlat9 = -_XSkyScale.w * _XSkyScale.z;
				u_xlat9 = u_xlat9 * 1.442695;
				u_xlat9 = exp2(u_xlat9);
				u_xlat3 = u_xlat3 * u_xlat9;
				u_xlat0.x = u_xlat3 * 0.25 + u_xlat0.x;

				u_xlat1.xyz = _XSky4PI.www + _XSky4PI.xyz;
				u_xlat0.xyw = ((-u_xlat0.xxx) * u_xlat1.xyz);
				u_xlat0.xyw = 1.442695 * u_xlat0.xyw;
				u_xlat0.xyw = exp2(u_xlat0.xyw);
				u_xlat0.xyz = u_xlat6 * u_xlat0.xyw;
				u_xlat0.xyz = (u_xlat0.xyz * _XSkySunSkyColor.xyz);
				u_xlat1.xyz = (u_xlat0.xyz *_XSkySun.xyz);
				u_xlat0.xyz = (u_xlat0.xyz * _XSkySun.www);

				float3 mieColor = u_xlat0.xyz * _XSkyMieColor.xyz;
				float3 rayleighColor = u_xlat1.xyz * _XSkyRayleighColor.xyz;

				Varyings output;
				output.positionCS = positionCS;
				output.normalWS = normalWS;
				output.mieColor = mieColor;
				output.rayleighColor = rayleighColor;
				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				float3 normalWS = normalize(input.normalWS);
				float NoL = dot(normalWS, _XSkyLocalMoonDirection);

				float moonHalo = pow(max(NoL, 0.0), _XSkyMoonHaloPower);
				float3 moonHaloColor = _XSkyMoonHaloColor * moonHalo;

				float dy = max(normalWS.y, 0.0);
				float3 moonSkyColor = (1 - 0.75 * dy) * _XSkyMoonSkyColor + moonHaloColor;
				float u_xlat9 = min(dy, 1.0) * _XSkyTopColorBlend;

				NoL = dot(normalWS, _XSkyLocalSunDirection);
				float u_xlat6 = 0.75 * (1 + NoL * NoL);
				float3 color = u_xlat6 * input.rayleighColor + moonSkyColor;

				u_xlat6 = _XSkyMie.z * NoL + _XSkyMie.y;
				u_xlat6 = pow(u_xlat6, 1.5);
				float u_xlat3 = _XSkyMie.x * (1 + NoL * NoL);
				u_xlat3 = u_xlat3 / u_xlat6;
				float3 u_xlat1 = u_xlat3 * input.mieColor + color;
				color = lerp(u_xlat1, _XSkyGroundColor.rgb, saturate(-normalWS.y));
				color = lerp(color, _XSkyTopColor.rgb, u_xlat9);

				color = lerp(color, _XSkyFogColor.rgb, _XSkyFogginess);
				color = pow(color * _XSkyBrightness, _XSkyContrast);

				u_xlat9 = dot(color.xy, float2(0.3, 0.59));
				u_xlat1 = 0.11 * color + u_xlat9;
				color = lerp(color, u_xlat1, _XSceneGray);
				color = lerp(color, color * _XSceneDarkColor.rgb, _XSceneDarkColor.w);
				return L2G(float4(color, _XSkyBloom));
			}
			ENDCG
		}
	}
}
