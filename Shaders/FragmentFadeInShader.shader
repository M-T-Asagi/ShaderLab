Shader "AsagiShader/FadeInShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _State ("State", Float) = 0.5
        _Thickness ("Thickness of edge", Range(0.0, 1.0)) = 0.1
        [HDR] _EmissionColor ("Emission color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
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

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _State;
        float _Thickness;
        fixed4 _EmissionColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            float dbauc = distance(IN.uv_MainTex, float2(0.5, 0.5));
            int isIn = step(dbauc, _State * 0.5);
            o.Alpha = c.a * (isIn + (1 - isIn) * (1 - min(distance(_State * 0.5, dbauc) / (_Thickness * 0.5), 1)));
            //o.Emission = _EmissionColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
