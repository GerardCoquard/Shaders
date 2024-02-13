Shader "Tecnocampus/GBufferShader"
{
    Properties
    {
        
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
            struct DeferredFragmentColors
            {
                float4 color0 : COLOR0;
                float4 color1 : COLOR1;
                float4 color2 : COLOR2;
            };



            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
             
                 o.uv= v.uv;
                return o;
             }

             DeferredFragmentColors frag (VERTEX_OUT i)
             {
                 DeferredFragmentColors l_Out = (DeferredFragmentColors)0;

                 return l_Out;
             }
             ENDCG
         }
    }
}
