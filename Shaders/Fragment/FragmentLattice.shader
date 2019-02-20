Shader "AsagiShader/FragmentLattice"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_BarColor ("Bar color", Color) = (0, 0, 0, 0)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NumOfSquareX ("number of square x", Int) = 10
		_NumOfSquareY ("number of square y", Int) = 10
        _LatticeThick ("Thickness(0 to 1)", Range(0.0, 1.0)) = 0.1
    }
    SubShader
    {
		Pass {
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert_img
			#pragma fragment frag

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
			};

			fixed4 _Color;
			fixed4 _BarColor;
			int _NumOfSquareX;
			int _NumOfSquareY;
			float _LatticeThick;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			float2 tiledPos(float2 _pos)
			{
				return (floor(_pos * float2(_NumOfSquareX, _NumOfSquareY)) + float2(0.5, 0.5)) / float2(_NumOfSquareX, _NumOfSquareY);
			}

			float2 posInPanel(float2 _pos)
			{
				return frac(_pos * float2(_NumOfSquareX, _NumOfSquareY));
			}

			fixed4 frag(v2f_img i) : SV_Target {
				float2 pos = posInPanel(i.uv);
				float isLattice = (step(0, pos.x) * (1 - step(_LatticeThick, pos.x))) + (step(pos.x, 1) * (1 - step(pos.x, 1 - _LatticeThick))) + 
					(step(0, pos.y) * (1 - step(_LatticeThick, pos.y))) + (step(pos.y, 1) * (1 - step(pos.y, 1 - _LatticeThick)));
				return _Color * (1 - isLattice) + _BarColor * isLattice;
			}
        
			ENDCG
		}
	}
    FallBack "Diffuse"
}
