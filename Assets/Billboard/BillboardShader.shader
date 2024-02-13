Shader "Tecnocampus/BillboardShader"
{
Properties
{
    _MainTex("MainTexture", 2D) = "defaulttexture"{}
    [Toggle] UseUpVector("UseUpVector", Float) = 0
    Size("Scale", Float) = 1
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
            float4 _RightDirection;
            float4 _UpDirection;
            float UseUpVector;
            float Size;


            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 float3 l_Position = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
                 o.vertex = float4(l_Position.xyz+_RightDirection*Size*(v.uv.x-0.5)*2.0+(UseUpVector==1.0 ? _UpDirection*Size: float3(0,1,0)) *(v.uv.y - 0.5)*2.0, 1.0);
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
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
