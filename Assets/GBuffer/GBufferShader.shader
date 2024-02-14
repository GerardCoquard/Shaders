Shader "Tecnocampus/GBufferShader"
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
                float3 normal : NORMAL;
                float2 depth : TEXCOORD0;

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float2 depth : TEXCOORD0;
            };

            sampler2D _MainTex;

            struct DeferredFragmentColors
            {
                float4 color0 : COLOR0;
                float4 color1 : COLOR1;
                float4 color2 : COLOR2;
            };

            float3 Normal2Texture(float3 _normal)
            {
                return (_normal + 1.0) * 0.5;
            };

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
             
                 o.uv= v.uv;
                 o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                 o.depth = o.vertex.zw;

                return o;
             }

             DeferredFragmentColors frag (VERTEX_OUT i)
             {
                 DeferredFragmentColors l_Out;
                 //Color
                 l_Out.color0 = float4(tex2D(_MainTex, i.uv).xyz,1);
                 //Normals
                 l_Out.color1 = float4(Normal2Texture(i.normal),1);
                 //Depth
                 float l_Depth = i.depth.x / i.depth.y;
                 l_Out.color2 = float4(l_Depth, l_Depth, l_Depth, l_Depth);

                 return l_Out;
             }
             ENDCG
         }
    }
}
