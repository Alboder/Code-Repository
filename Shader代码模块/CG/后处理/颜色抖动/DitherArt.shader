Shader "Custom Art/DitherArt"{
    Properties{
        _MainTex("Texture",2D) = "white"{}
        _DitherTex("Dither Texture", 2D) = "white"{}
        _ColorRamp("Color Ramp", 2D) = "white"{}
    }

    SubShader{
        Tags{
            "RenderType"="Opaque"
        }
        LOD 200

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
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            sampler2D _DitherTex;
            float4 _DitherTex_TexelSize;

            sampler2D _ColorRamp;

            float Dither8X8(int x, int y, float brightness){
                const float dither[64] = {
                    0,32,8,40,2,34,10,42,
                    48,16,56,24,50,18,58,26,
                    12,44,4,36,14,46,6,38,
                    60,28,52,20,62,30,54,22,
                    3,35,11,43,1,33,9,41,
                    51,19,59,27,49,17,57,25,
                    15,47,7,39,13,45,5,37,
                    63,31,55,23,61,29,53,21
                };
                int r = y * 8 + x;
                float result = step(dither[r], brightness * 64);
                return result;
            }


            v2f vert(appdata v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed4 col = tex2D(_MainTex, i.uv);
                float lum = dot(col, float3(0.299f,0.587f, 0.114f));

                float2 ditherCoords = i.uv * _DitherTex_TexelSize.xy * _MainTex_TexelSize.zw;
                float ditherLum = tex2D(_DitherTex, ditherCoords);
                float ramp = (lum <= clamp(ditherLum, 0.1f, 0.9f)) ? 0.1f : 0.9f;
                float3 output = tex2D(_ColorRamp, float2(ramp, 0.5f));

                //ÏñËØµãµÄÆÁÄ»×ø±ê
                //half2 uv = i.position.xy / i.position.w * _ScreenParams.xy;
                //half2 uv = i.texcoord * _ScreenParams.xy;
                //int ditherSize = 8;
                //float dither = Dither8X8(uv.x % ditherSize, uv.y % ditherSize, lum);
                //dither += 1;
                //col *= dither;

                //return col;

                return col * (ramp + 0.5f);
            }


            ENDCG
        }
        
    }
}
