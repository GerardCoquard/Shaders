Shader "Tecnocampus/TerrainShader"
{
    Properties
    {
        _HeightmapTex("Heightmap", 2D) = "defaulttexture"{}
        _HeatmapTex("Heatmap", 2D) = "defaulttexture"{}
        _MaxHeight("MaxHeight", Float) = 10
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
            sampler2D _HeightmapTex;
            sampler2D _HeatmapTex;
            float4 _HeatmapTex_ST;
            float4 _HeightmapTex_ST;
            float _MaxHeight;

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 float l_Height = tex2Dlod(_HeightmapTex, float4(v.uv, 0,0)).x*_MaxHeight;
                 o.vertex.y += l_Height;
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 o.uv=v.uv;
                 
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float l_Heightmap = tex2D(_HeightmapTex,i.uv);
                 float4 l_color = tex2D(_HeatmapTex,float2(0.5, l_Heightmap));
                 return l_color;
             }
             ENDCG
         }
    }
}
