Shader "Tecnocampus/SkinningShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        
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
                float4 Weights : TEXCOORD1;
                float4 Indices : TEXCOORD2;

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4x4 g_Bones[29];
            int maxBones;

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 float3 l_Position = mul(g_Bones[v.Indices.x], float4(v.vertex.xyz, 1.0))* v.Weights.x;
                l_Position += mul(g_Bones[v.Indices.y], float4(v.vertex.xyz, 1.0)) * v.Weights.y;
                l_Position += mul(g_Bones[v.Indices.z], float4(v.vertex.xyz, 1.0)) * v.Weights.z;
                l_Position += mul(g_Bones[v.Indices.w], float4(v.vertex.xyz, 1.0)) * v.Weights.w;

                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(l_Position, 1.0));
                 
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex); ESTO ES TILLING, o.uv = v.uv NO ES TILLING, SIMPLE
                 //o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                 o.uv= TRANSFORM_TEX(v.uv, _MainTex);
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
