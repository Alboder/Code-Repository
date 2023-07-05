Shader "Custom Art/PixelArt"{
	Properties{
		_MainTex("Texture",2D) = "white"{}
		_Intensity("Pixelate Intensity",Float) = 128
		_ColorLevel("ColorLevel",Float) = 5
	}
	SubShader{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 position : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float _Intensity;
			float _ColorLevel;

			v2f vert(appdata v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.uv;
				return o;
			}

			//RGB2HSV
			float3 rgb2hsv(float3 rgb){
				float3 hsv;
				float R = rgb.x;
				float G = rgb.y;
				float B = rgb.z;
				float Max = max(R, max(G, B));
				float Min = min(R, max(G, B));
				if(R == Max){
					hsv.x = (G - B) / (Max - Min);
				}
				if(G == Max){
					hsv.x = 2 + (B - R) / (Max - Min);
				}
				if(B == Max){
					hsv.x = 4 + (R - G) / (Max - Min);
				}
				hsv.x = hsv.x * 60.0;
				if(hsv.x < 0){
					hsv.x += 360;
				}
				hsv.y = (Max - Min) / Max;
				hsv.z = Max;
				return hsv;
			}

			//HSV2RGB 
			float3 hsv2rgb(float3 hsv){
				float3 rgb;
				if(hsv.y == 0){
					rgb = hsv.z;
				}else{
					hsv.x = hsv.x / 60.0;
					int i = (int)hsv.x;
					float f = hsv.x - (half)i;
					float a = hsv.z * (1 - hsv.y);
					float b = hsv.z * (1 - hsv.y * f);
					float c = hsv.z * (1 - hsv.y * (1 - f));
					switch(i){
						case 0:
							rgb.x = hsv.z;
							rgb.y = c;
							rgb.z = a;
							break;
						case 1:
							rgb.x = b;
							rgb.y = hsv.z;
							rgb.z = a;
							break;
						case 2:
							rgb.x = a;
							rgb.y = hsv.z;
							rgb.z = c;
							break;
						case 3:
							rgb.x = a;
							rgb.y = b;
							rgb.z = hsv.z;
							break;
						case 4:
							rgb.x = c;
							rgb.y = a;
							rgb.z = hsv.z;
							break;
						default:
							rgb.x = hsv.z;
							rgb.y = a;
							rgb.z = b;
							break;
					}
				}
				return rgb;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				float2 uv = i.texcoord;
				uv.x *= _Intensity;
				uv.y *= _Intensity;
				uv.x = round(uv.x);
				uv.y = round(uv.y);
				uv.x /= _Intensity;
				uv.y /= _Intensity;
				fixed4 col = tex2D(_MainTex, uv);
				float lum = dot(col, float3(0.299f,0.587f, 0.114f));
				lum *= _ColorLevel;
				lum = ceil(lum);
				lum /= _ColorLevel;
				lum += 0.7f;
				return col * lum;
			}


			ENDCG
		}
	
	}
}
