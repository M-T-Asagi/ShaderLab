Shader "Custom/Sonar" {
	Properties {
		_BackgroundTex("Main texture(RGB)", 2D) = "white"{}
		_BackgroundColor("Background Color", Color) = (0,0,0,1)
		_LineTex("Line texture(RGB)", 2D) = "white"{}
		_LineColor("Line Color", Color) = (1,1,1,1)
		_UpFade("Fade of up on line center", Range(0.0, 1.0)) = 0.1
		_DownFade("Fade of under line center", Range(0.0, 1.0)) = 0.1
		_Tickness("Tickness", Range(0.0, 1.0)) = 0.1
		_SpawnSpan("Spawn time", Float) = 3
		_LoopTime("Loop time", Float) = 3
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
			float _SpawnSpan;
			float _LoopTime;

			fixed4 drawLine(v2f_img i) {
				float time = fmod(_Time.y, _LoopTime);
				float timePersent = time / _LoopTime;
				float lineBottom = timePersent - _Tickness * 0.5;
				float lineTop = timePersent + _Tickness * 0.5;
				float power =
					step(lineBottom, i.uv.y) * step(i.uv.y, lineTop) +
					step(i.uv.y, lineBottom) * max((_DownFade - distance(lineBottom, i.uv.y)) / _DownFade, 0) +
					step(lineTop, i.uv.y) * max((_UpFade - distance(lineTop, i.uv.y)) / _UpFade, 0);

				return power * _LineColor * tex2D(_LineTex, i.uv) + (1 - power) * _BackgroundColor * tex2D(_BackgroundTex, i.uv);
			}

			float getLinePower(float pos, float lineCenter)
			{
				float lineBottom = lineCenter - _Tickness * 0.5;
				float lineTop = lineCenter + _Tickness * 0.5;
				return step(lineBottom, pos) * step(pos, lineTop) +
					step(pos, lineBottom) * max((_DownFade - distance(lineBottom, pos)) / _DownFade, 0) +
					step(lineTop, pos) * max((_UpFade - distance(lineTop, pos)) / _UpFade, 0);
			}

			fixed4 frag (v2f_img i) : SV_Target {
				float percentOfSpawnSpan = _SpawnSpan / _LoopTime;
				float lastSpawned = floor(_Time.y / _SpawnSpan) * _SpawnSpan;
				float elapsedTimeSinceLastSpawned = _Time.y - lastSpawned;
				float elapsedPercentSinceLastSpawned = elapsedTimeSinceLastSpawned / _LoopTime;
				float thisYInWhatNumOfSpawned = floor((i.uv.y - elapsedPercentSinceLastSpawned) / percentOfSpawnSpan);
				float bottomPower = getLinePower(i.uv.y, thisYInWhatNumOfSpawned * percentOfSpawnSpan + elapsedPercentSinceLastSpawned);
				float topPower = getLinePower(i.uv.y, (thisYInWhatNumOfSpawned + 1) * percentOfSpawnSpan + elapsedPercentSinceLastSpawned);
				float power = min(topPower + bottomPower, 1);
				fixed4 col = power * _LineColor * tex2D(_LineTex, i.uv) + (1 - power) * _BackgroundColor * tex2D(_BackgroundTex, i.uv);
				return col;
			}

            ENDCG
        }
	}
	FallBack "Diffuse"
}
