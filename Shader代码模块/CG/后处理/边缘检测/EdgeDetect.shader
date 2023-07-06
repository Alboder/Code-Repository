Shader "Custom Art/Simple Edge Dection" {
	Properties {
		[HideInInspector]_MainTex("Texture", 2D) = "white"{}
		_Brightness("Brightness", Range(0, 1)) = 1
		_Saturate("Saturate", Range(0, 1)) = 1
		_Contrast("Contrast", Range(-1, 2)) = 1
		_EdgeOnly("EdgeOnlt", Range(0, 1)) = 1

		_EdgeColor("EdgeColor", Color) = (1,1,1,1)
		_BackgroundColor("Background Color", Color) = (1,1,1,1)


		_Delta("Line Thickness", Range(0.0005, 0.0025)) = 0.001
	}
	SubShader {
		Tags {
			"RenderType"="Opaque"
		}

		Cull Off
		ZWrite Off
		ZTest Always

		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float _Brightness;
			float _Saturate;
			float _Contrast;
			float _Delta;
			float _EdgeOnly;
			float4 _EdgeColor;
			float4 _BackgroundColor;

			//获取明度
			float luminance(half4 col) {
				float gray = 0.21f * col.x + 0.72 * col.y + 0.072 * col.z;
				return gray;
			}

			//获取uv处像素的sabel值
			float sobel(float2 uv) {
				float h = 0;
				float v = 0;

				float2 delta = float2(_Delta, _Delta);
				h += luminance(tex2D(_MainTex, uv + float2(-1.0, -1.0) * delta) *  1.0);
                h += luminance(tex2D(_MainTex, uv + float2( 1.0, -1.0) * delta) * -1.0);
                h += luminance(tex2D(_MainTex, uv + float2(-1.0,  0.0) * delta) *  2.0);
                h += luminance(tex2D(_MainTex, uv + float2( 1.0,  0.0) * delta) * -2.0);
                h += luminance(tex2D(_MainTex, uv + float2(-1.0,  1.0) * delta) *  1.0);
                h += luminance(tex2D(_MainTex, uv + float2( 1.0,  1.0) * delta) * -1.0);

                v += luminance(tex2D(_MainTex, uv + float2(-1.0, -1.0) * delta) *  1.0);
                v += luminance(tex2D(_MainTex, uv + float2( 0.0, -1.0) * delta) *  2.0);
                v += luminance(tex2D(_MainTex, uv + float2( 1.0, -1.0) * delta) *  1.0);
                v += luminance(tex2D(_MainTex, uv + float2(-1.0,  1.0) * delta) * -1.0);
                v += luminance(tex2D(_MainTex, uv + float2( 0.0,  1.0) * delta) * -2.0);
                v += luminance(tex2D(_MainTex, uv + float2( 1.0,  1.0) * delta) * -1.0);

				return sqrt(h * h + v * v);
			}

			v2f vert(appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				float s = sobel(i.uv);
				fixed4 edgeOnlyColor = lerp(_EdgeColor, _BackgroundColor, s);
				fixed4 edgeWithColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv), step(0.1, s));
				//fixed4 col = lerp(edgeWithColor, edgeOnlyColor, _EdgeOnly);
				fixed4 col = tex2D(_MainTex, i.uv);
				col -= s;
				return col;
			}


			ENDCG
		}

		


	}
}
