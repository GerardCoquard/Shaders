Shader "Tecnocampus/WindShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        _WindDirection("Wind Direction", Vector) = (1.0,0.5,0.0,0.0)
        _Amplitude("Amplitude", Float) = 1
        _Speed("Speed", Float) = 2
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
            float4 _WindDirection;
            float _Amplitude;
            float _Speed;

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 float3 l_WindDirection=normalize(_WindDirection.xyz)*_Amplitude*v.uv.y*cos(_Time.y*_Speed);
                 
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex); ESTO ES TILLING, o.uv = v.uv NO ES TILLING, SIMPLE
                 //o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                 o.uv= TRANSFORM_TEX(v.uv, _MainTex);
                 o.uv.x += l_WindDirection;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float4 l_color = tex2D(_MainTex,i.uv);
                 return l_color;
             }
             ENDCG
         }
    }
}
