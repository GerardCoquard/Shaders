Shader "Tecnocampus/PreBloomShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        _Threshold("Threshold", Range(0.0,1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            sampler2D _SourceTex;
            float4 _SourceTex_ST;
            float _Threshold;


            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex); ESTO ES TILLING, o.uv = v.uv NO ES TILLING, SIMPLE
                 o.uv= v.uv;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float4 l_Color = tex2D(_SourceTex,i.uv);
                 return saturate((l_Color-_Threshold)/(1.0-_Threshold));
             }
             ENDCG
         }
    }
}
