Shader "AsagiShader/SonarManually" {
	Properties{
		_BackgroundTex("Main texture(RGB)", 2D) = "white"{}
		_BackgroundColor("Background Color", Color) = (0,0,0,1)
		_LineTex("Line texture(RGB)", 2D) = "white"{}
		_LineColor("Line Color", Color) = (1,1,1,1)
		_UpFade("Fade of up on line center", Range(0.0, 1.0)) = 0.1
		_DownFade("Fade of under line center", Range(0.0, 1.0)) = 0.1
		_Tickness("Tickness", Range(0.0, 1.0)) = 0.1
		_State("State", Range(-2.0, 3.0)) = -1
	}

		SubShader
		{
			Pass
			{
				CGPROGRAM
				#include "UnityCG.cginc"
				#pragma vertex vert_img
				#pragma fragment frag

				sampler2D _BackgroundTex;
				fixed4 _BackgroundColor;
				sampler2D _LineTex;
				fixed4 _LineColor;
				float _UpFade;
				float _DownFade;
				float _Tickness;
				float _State;

				float getLinePower(float pos, float lineCenter)
				{
					float lineBottom = lineCenter - _Tickness * 0.5;
					float lineTop = lineCenter + _Tickness * 0.5;
					return step(lineBottom, pos) * step(pos, lineTop) +
						step(pos, lineBottom) * max((_DownFade - distance(lineBottom, pos)) / _DownFade, 0) +
						step(lineTop, pos) * max((_UpFade - distance(lineTop, pos)) / _UpFade, 0);
				}

				fixed4 frag(v2f_img i) : SV_Target{
					float power = getLinePower(i.uv.y, _State);
					fixed4 col = power * _LineColor * tex2D(_LineTex, i.uv) + (1 - power) * _BackgroundColor * tex2D(_BackgroundTex, i.uv);
					return col;
				}
				ENDCG
			}
		}
			FallBack "Diffuse"
}
