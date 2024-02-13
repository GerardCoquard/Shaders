Shader "Tecnocampus/AlphaClipShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        _RangeValue("CutOff", Range(0.0,1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
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
                float2 uv : TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RangeValue;

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex);
                 o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float4 l_color = tex2D(_MainTex,i.uv);
                 //if(l_color.w <= _RangeValue) clip(-1);
                 //else clip(1);
                      //discard;
                 clip(l_color.w - _RangeValue);
                 return l_color;
             }
             ENDCG
         }
    }
}
