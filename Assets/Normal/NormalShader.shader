Shader "Tecnocampus/NormalShader"
{
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
                float3 normal : NORMAL;
            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };


            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
                 o.normal=mul((float3x3)unity_ObjectToWorld, v.normal);
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float3 normalized = normalize(i.normal);
                 return float4(normalized,1.0);
             }
             ENDCG
         }
    }
}
