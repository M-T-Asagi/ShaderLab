Shader "Ballboy/EyeDisplayShader" {
	Properties {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[MaterialToggle]
		_DottingTex("画像のドット化", Int) = 1
		[MaterialToggle]
		_SquareDot("チェック→四角いドット。アンチェック→丸ドット", Int) = 1
		_ResolutionX("解像度 (X)", Int) = 200
		_ResolutionY("解像度 (Y)", Int) = 40
		_SizeOfDots("1セルごとの非表示領域に対する表示領域の比率", Range(0.0, 1.0)) = 0.9
		[HDR]
		_BackLightColor("Back light color", Color) = (1,1,1,1)
		_UnDiplayedLineColor("ドットとドットの間の色", Color) = (1,1,1,1)
		_DiffuseColor("Diffuse color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		int _DottingTex;
		int _SquareDot;
		int _ResolutionX;
		int _ResolutionY;
		float _SizeOfDots;
		fixed4 _BackLightColor;
		fixed4 _UnDiplayedLineColor;
		fixed4 _DiffuseColor;

		half _Glossiness;
		half _Metallic;
		

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			float2 uv = IN.uv_MainTex;
			float2 checkUV = float2(frac(uv.x * _ResolutionX), frac(uv.y * _ResolutionY));
			float2 pixeled = float2(floor(uv.x * _ResolutionX) / _ResolutionX, floor(uv.y * _ResolutionY) / _ResolutionY);
			float size = 0.5 + _SizeOfDots * 0.5;
			float2 disp = 
				(_SquareDot * step(checkUV, size) * step(1.0 - checkUV, size))
				+ ((1 - _SquareDot) * step(distance(checkUV, float2(0.5, 0.5)), _SizeOfDots));
			float _disp = disp.x * disp.y;
			fixed4 displayed = (
				(_disp * tex2D(
					_MainTex, (_DottingTex * pixeled + (1 - _DottingTex) * uv)
				)) + ((1 - _disp) * _UnDiplayedLineColor));
			
			fixed4 c = displayed * _DiffuseColor;
			o.Emission = displayed * _BackLightColor;

			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
