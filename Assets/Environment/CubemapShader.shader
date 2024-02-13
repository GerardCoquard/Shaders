Shader "Tecnocampus/CubemapShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        _EnvironmentTex ("Cubemap", Cube) = "" {}
        _RangeValue("EnvironmentAmount", Range(0.0,1.0)) = 0.5
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

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 WorldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _EnvironmentTex;
            float _RangeValue;


            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.WorldPosition = o.vertex;
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
                 o.normal=mul((float3x3)unity_ObjectToWorld, v.normal);

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex);
                 o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float3 envToCam = normalize(i.WorldPosition - _WorldSpaceCameraPos);
                 float3 normal = normalize(i.normal);
                 float3 reflected = reflect(envToCam,normal);
                 float4 cubemap_color = texCUBE(_EnvironmentTex,reflected);
                 float4 text_color = tex2D(_MainTex,i.uv);
                 return cubemap_color*_RangeValue + text_color*(1-_RangeValue);
             }
             ENDCG
         }
    }
}
