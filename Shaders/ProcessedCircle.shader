Shader "Custom/ProcessedCircle" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_Thickness("Thickness", Range(0.0, 1.0)) = 0.1
		_Radius("Radius", Range(0.0, 1.0)) = 0.5
		_State("State", Range(0.0, 1.0)) = 0
		_Rotation("Rotation", Range(0.0, 360.0)) = 180
	}
		SubShader
	{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert_img
			#pragma fragment frag

			fixed4 _Color;
			float _Thickness;
			float _Radius;
			float _State;
			float _Rotation;

			fixed4 frag(v2f_img i) : SV_Target {
				float distanceFromCenter = distance(float2(0.5, 0.5), i.uv);
				float rad = _Radius / 2.0;
				float thick = _Thickness / 2.0;
				float radOfPos = atan2(i.uv.x - 0.5, i.uv.y - 0.5) + radians(180);
				radOfPos = fmod(radOfPos + radians(_Rotation), radians(360));
				return _Color *
					step(distanceFromCenter, rad + thick) *
					step(rad - thick, distanceFromCenter) *
					step(radOfPos, radians(_State * 360.0));
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}
