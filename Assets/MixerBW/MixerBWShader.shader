Shader"Tecnocampus/MixerBWShader"
{
Properties
{
    _WhiteTex("WhiteTex", 2D) = "defaulttexture" {}
    _BlackTex("BlackTex", 2D) = "" {}
    _MixTex("MixTex", 2D) = "" {}
}
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VERTEX_IN
            {
                 float4 vertex : POSITION;
                 float2 uv : TEXCOORD0;
            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uvMixer : TEXCOORD0;
                float2 uvBlack : TEXCOORD1;
                float2 uvWhite : TEXCOORD2;
                
            };
                sampler2D _WhiteTex;
                sampler2D _BlackTex;
                sampler2D _MixTex;
                float4 _MixTex_ST;

                float4 _WhiteTex_ST;
                float4 _BlackTex_ST;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //De local a mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //De mundo a view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //De view a proyección
                o.uvMixer = v.uv;
                
                 o.uvBlack = TRANSFORM_TEX(v.uv, _BlackTex);
                 o.uvWhite = TRANSFORM_TEX(v.uv, _WhiteTex);
   
                 
             return o;
            }

            


            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_mixColor = tex2D(_MixTex, i.uvMixer);
                float4 l_blackColor = tex2D(_BlackTex, i.uvBlack);
                float4 l_whiteColor = tex2D(_WhiteTex, i.uvWhite);
                
                return float4(l_mixColor.x * l_whiteColor.xyz + (1.0-l_mixColor.x)*l_blackColor.xyz, 1.0);

}
             ENDCG
         }
    }
}

