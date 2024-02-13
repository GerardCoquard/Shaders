Shader "Tecnocampus/SkyboxShader"
{
    Properties
    {
        _EnvironmentTex ("Cubemap", Cube) = "" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
        LOD 100

        Pass
        {
            
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VERTEX_IN
            {
                float4 vertex : POSITION;

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };
            samplerCUBE _EnvironmentTex;

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 float3 l_normal = normalize(v.vertex.xyz);
                 o.vertex= float4(_WorldSpaceCameraPos + l_normal * _ProjectionParams.z * 0.5, 1.0);
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
                 o.normal= l_normal;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float3 Nn = normalize(i.normal);
                 return texCUBE(_EnvironmentTex,Nn);
             }
             ENDCG
         }
    }
}
