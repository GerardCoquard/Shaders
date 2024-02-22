Shader "Tecnocampus/ShadowMapShader"
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

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 depth : TEXCOORD0;
            };

            sampler2D _MainTex;

            

            

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
             
                 o.depth = o.vertex.zw;

                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 //Depth
                 float l_Depth = i.depth.x / i.depth.y;
                 return float4(l_Depth, l_Depth, l_Depth, l_Depth);
             }
             ENDCG
         }
    }
}
