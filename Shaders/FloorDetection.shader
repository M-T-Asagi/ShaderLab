Shader "Custom/FloorDetection" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_PanelTex("Panel tex", 2D) = "white" {}
        [HDR]_EmissionColor("Emission color", Color) = (1, 1, 1, 1)
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Tiling("Tiling", Int) = 10
		_State("State", Range(-1.0, 2.0)) = 0.5
		_MaxDistance("max Distance", Range(0.0, 1.0)) = 0.1
	}
		SubShader{
			Tags{
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
			}
			Blend SrcAlpha OneMinusSrcAlpha
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows alpha:fade

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _PanelTex;

			struct Input {
				float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
            fixed4 _EmissionColor;
			float _Tiling;
			float _State;
			float _MaxDistance;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			float2 tiledPos(float2 _pos)
			{
				return (floor(_pos * _Tiling) + float2(0.5, 0.5)) / _Tiling;
			}

			float distanceWithStateAndDecay(float2 _pos)
			{
				return min(1, distance(_State, distance(_pos, float2(0.5, 0.5)) * 2.0) / _MaxDistance);
			}

			float2 posInPanel(float2 _pos)
			{
				return frac(_pos * _Tiling);
			}

			void surf(Input IN, inout SurfaceOutputStandard o) {
				// Albedo comes from a texture tinted by color
                float power = 1.0 - distanceWithStateAndDecay(tiledPos(IN.uv_MainTex));
				fixed4 c = power * tex2D(_MainTex, IN.uv_MainTex) * _Color * tex2D(_PanelTex, posInPanel(IN.uv_MainTex));
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
                o.Emission = power * _EmissionColor;
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
