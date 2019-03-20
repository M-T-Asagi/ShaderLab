Shader "AsagiShader/LightWall"
{
   Properties{
		_MainTex("Main texture(RGB)", 2D) = "white"{}
		_MainColor("Main Color", Color) = (0,0,0,1)
		_Seed("randomize seed", Float) = 100
		_TimeScale("time scale", Float) = 1
		_WaveScale ("wave scale", Int) = 1.0
		_WaveMaxMoves ("wave moves", Range(0, 1)) = 0.5
		_RandomScale ("randomed number scale", Float) = 10
	}

	SubShader
	{
		Tags{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			fixed4 _MainColor;
			sampler2D _LineTex;
			float _Seed;
			float _TimeScale;
			int _WaveScale;
			float _WaveMaxMoves;
			float _RandomScale;

			float random (fixed2 p) { 
				return frac(sin(dot(p, fixed2(12.9898,78.233))) * 43758.5453);
			}

			struct appdata
            {
                float2 uv : TEXCOORD0;
				float4 vertex : POSITION;
            };

			struct v2f
            {
                float2 uv : TEXCOORD0;
				 UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 rands : TEXCOORD1;
            };

			v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.rands.x = random(float2(_Seed + 1, _Seed + 1));
				o.rands.y = random(float2(_Seed + 2, _Seed + 2));
				o.rands.z = random(float2(_Seed + 3, _Seed + 3));
				o.rands.w = random(float2(_Seed + 4, _Seed + 4));
                return o;
            }

			fixed4 frag(v2f i) : SV_Target{
				float PI = 3.14159265f;
				int4 rands = floor(i.rands * _RandomScale);
				rands += rands % 2;
				
				int waveScale = _WaveScale + _WaveScale % 2;

				// 高さを出す部分と左右移動の部分で_TimeScale等の値を共有しているので修正する
				float maxHeight =
					// ベースとなる波形の生成
					(
						sin(i.uv.x * PI * rands.x) +
						sin(i.uv.x * PI * rands.y) +
						sin(i.uv.x * PI * rands.z) +
						sin(i.uv.x * PI * rands.w)
					) / 4.0 * (1.0 - _WaveMaxMoves) * (0.5 - 0.025)

					// 高さの動きを生成
					+ sin(i.uv.x * PI * waveScale) * _WaveMaxMoves * (0.5 - 0.025) * sin(_Time.y * _TimeScale)

					// アクセントとしての左右移動を生成
					+ sin(i.uv.x * PI * waveScale + _Time.y * _TimeScale) * 0.05
					+ 0.5;
				float power = step(i.uv.y, maxHeight);
				return power * _MainColor * tex2D(_MainTex, float2(i.uv.x, i.uv.y / maxHeight));
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
	