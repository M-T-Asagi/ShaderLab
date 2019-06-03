Shader "AsagiShader/FragmentGradient"
{
    Properties
    {
        _FromColor ("from Color", Color) = (1,1,1,1)
        _ToColor ("to Color", Color) = (1, 1, 1, 1)
        _CenterX ("center position of X", float) = 0.5
        _CenterY ("center position of Y", float) = 1.0
        _Direction ("direction(0=y to -y, 0.25 = x to -x...)", Range(0, 2.0)) = 0.0
    }
    SubShader
    {
        Tags{
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200
            
        Pass{
            CGPROGRAM
            // Physically based Standard lighting model, and enable shadows on all light types
            #include "UnityCG.cginc"
            #pragma vertex vert_img
            #pragma fragment frag

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _MainTex;

            struct v2f
            {
                float2 uv : TEXCOORD0;
            };
            
            fixed4 _FromColor;
            fixed4 _ToColor;
            float _CenterX;
            float _CenterY;
            float _Direction;
            
            static const float PI = 3.14159265f;

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            fixed4 frag(v2f i) : SV_Target{
                float2 rate = float2(abs(sin(_Direction * PI)), abs(cos(_Direction * PI)));
                float power = distance(i.uv.x, _CenterX) * rate.x + distance(i.uv.y, _CenterY) * rate.y;
                return fixed4(_FromColor * (1.0 - power) + _ToColor * power);
            }
                
            ENDCG
        }
    }
    FallBack "Diffuse"
}
