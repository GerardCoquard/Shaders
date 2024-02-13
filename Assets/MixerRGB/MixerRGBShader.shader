Shader"Tecnocampus/MixerRGBShader"
{
Properties
{
    _RedTex("RedTex", 2D) = "defaulttexture" {}
    _GreenTex("GreenTex", 2D) = "" {}
    _BlueTex("BlueTex", 2D) = "" {}
    _AlphaTex("AlphaTex", 2D) = "" {}
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
                float2 uvRed : TEXCOORD1;
                float2 uvGreen : TEXCOORD2;
                float2 uvBlue : TEXCOORD3;
                float2 uvAlpha : TEXCOORD4;
                
            };
                sampler2D _RedTex;
                sampler2D _GreenTex;
                sampler2D _BlueTex;
                sampler2D _AlphaTex;
                sampler2D _MixTex;
                float4 _RedTex_ST;
                float4 _GreenTex_ST;
                float4 _BlueTex_ST;
                float4 _AlphaTex_ST;
                float4 _MixTex_ST;

            

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //De local a mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //De mundo a view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //De view a proyección
                o.uvMixer = v.uv;
                
                o.uvRed = TRANSFORM_TEX(v.uv, _RedTex);
                o.uvGreen = TRANSFORM_TEX(v.uv, _GreenTex);
                o.uvBlue = TRANSFORM_TEX(v.uv, _BlueTex);
                o.uvAlpha = TRANSFORM_TEX(v.uv, _AlphaTex);
   
                 
             return o;
            }

            


            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_mixColor = tex2D(_MixTex, i.uvMixer);
                float4 l_RedColor = tex2D(_RedTex, i.uvRed);
                float4 l_GreenColor = tex2D(_GreenTex, i.uvGreen);
                float4 l_BlueColor = tex2D(_BlueTex, i.uvBlue);
                float4 l_AlphaColor = tex2D(_AlphaTex, i.uvAlpha);
                
                return float4(l_mixColor.x * l_RedColor.xyz + l_mixColor.y * l_GreenColor.xyz + l_mixColor.z * l_BlueColor.xyz + l_mixColor.w * l_AlphaColor.xyz,1.0);

}
             ENDCG
         }
    }
}

