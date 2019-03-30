Shader "AsagiShader/WavingFrags"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HDR] _EmissionColor("Color", Color) = (1,1,1,1)
		_EmissionTex("Emission Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_TimeScale("Time scaling", Float) = 1.0
		_RandomSeed("randomize seed", Float) = 100
		_RandomScale("Random Scale", Vector) = (1.0, 1.0, 1.0, 1.0)
		_WaveScaleTexture("wave scalling from texture(RGB)", 2D) = "white" {}
		_WaveUpDirection ("Up direction of wave", Vector) = (0, 1, 0, 0)
		_WaveHorizontalDirection ("Horizontal direction of wave", Vector) = (0, 0, 1, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
		#pragma vertex vert
        #pragma surface surf Standard addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _EmissionTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		fixed4 _EmissionColor;

		float _TimeScale;
		float _RandomSeed;
		float4 _RandomScale;
		sampler2D _WaveScaleTexture;
		float4 _WaveScaleTexture_ST;
		float _WaveEffectionDistance;
		float4 _WaveUpDirection;
		float4 _WaveHorizontalDirection;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		float random(fixed2 p) {
			return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
		}

		void vert(inout appdata_full v)
		{
			float PI = 3.14159265f;
			float3 centerWpos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			float4 rands = float4(
					random(fixed2(centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed, centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 1)),
					random(fixed2(centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 2, centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 3)),
					random(fixed2(centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 4, centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 5)),
					random(fixed2(centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 6, centerWpos.x + centerWpos.y + centerWpos.z + _RandomSeed + 7))
				);

			float4 waves = float4(
					(sin(_WaveHorizontalDirection.x * (v.vertex.x * rands.x + _Time.y * _TimeScale * rands.x * PI)) +
						sin(_WaveHorizontalDirection.y * (v.vertex.y * rands.x + _Time.y * _TimeScale * rands.x * PI)) +
						sin(_WaveHorizontalDirection.z * (v.vertex.z * rands.x + _Time.y * _TimeScale * rands.x * PI))) * _RandomScale.x,
					(sin(_WaveHorizontalDirection.x * (v.vertex.x * rands.y + _Time.y * _TimeScale * rands.y * PI)) +
					sin(_WaveHorizontalDirection.y * (v.vertex.y * rands.y + _Time.y * _TimeScale * rands.y * PI)) +
					sin(_WaveHorizontalDirection.z * (v.vertex.z * rands.y + _Time.y * _TimeScale * rands.y * PI))) * _RandomScale.y,
					(sin(_WaveHorizontalDirection.x * (v.vertex.x * rands.z + _Time.y * _TimeScale * rands.z * PI)) +
					sin(_WaveHorizontalDirection.y * (v.vertex.y * rands.z + _Time.y * _TimeScale * rands.z * PI)) +
					sin(_WaveHorizontalDirection.z * (v.vertex.z * rands.z + _Time.y * _TimeScale * rands.z * PI))) * _RandomScale.z,
					(sin(_WaveHorizontalDirection.x * (v.vertex.x * rands.w + _Time.y * _TimeScale * rands.w * PI)) +
					sin(_WaveHorizontalDirection.y * (v.vertex.y * rands.w + _Time.y * _TimeScale * rands.w * PI)) +
					sin(_WaveHorizontalDirection.z * (v.vertex.z * rands.w + _Time.y * _TimeScale * rands.w * PI))) * _RandomScale.w
				);

			half2  uv = TRANSFORM_TEX(v.texcoord, _WaveScaleTexture);
			fixed4 c = tex2Dlod(_WaveScaleTexture, float4(uv.xy, 0, 0));

			float moves =
				(waves.x + waves.y + waves.z + waves.w) /
				(_RandomScale.x + _RandomScale.y + _RandomScale.z + _RandomScale.w) *
				c.r * c.g * c.b;
			
			v.vertex.xyz += _WaveUpDirection.xyz * moves;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
			o.Emission = tex2D(_EmissionTex, IN.uv_MainTex).rgb * _EmissionColor.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
