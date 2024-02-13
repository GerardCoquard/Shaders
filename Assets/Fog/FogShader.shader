Shader"Tecnocampus/BasicShader"
{
Properties
{
    _HeightTex("HeightTex", 2D) = "" {}
    _HeatMap("HeatTex", 2D) = "" {}
    _MaxHeight("Height", Range(0.0, 1500)) = 100
    _FogStartDistance("FogStartDistance", Float) = 1
    _FogEndDistance("FogEndDistance", Float) = 1
    _FogColor("FogColor", Color) = (1,0,0,1)
    [KeywordEnum(Linear, Exp, Exp2)] _FogType("Fog Type", Float) = 0
}
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #pragma multi_compile_FOGTYPE_LINEAR_FOGTYPE_EXP_FOGTYPE_EXP2

            struct appdata
            {
                 float4 vertex : POSITION;
                 float2 uv : TEXCOORD0;
    float3 WorldPosition : TEXCOORD1;
};
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
    float3 WorldPosition : TEXCOORD1;
                
            };
            sampler2D _HeatMap;
            sampler2D _HeightTex;
            float _MaxHeight;
            float _FogStartDistance;
            float _FogEndDistance;
            float4 _FogColor;

            v2f vert(appdata v)
            {
                v2f o;
                
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //De local a mundo
                float l_height = tex2Dlod(_HeightTex, float4(v.uv, 0, 0)).x * _MaxHeight;
                o.WorldPosition = o.vertex;
                o.vertex.y = l_height;
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //De mundo a view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //De view a proyección
                o.uv = v.uv;
   
                 
             return o;
            }

            


            fixed4 frag(v2f i) : SV_Target
            {
                float4 l_heightColor = tex2D(_HeightTex, i.uv);
                float4 l_heatColor = tex2D(_HeatMap, float2(0.5, l_heightColor.x));
                float l_Depth = length(i.WorldPosition - _WorldSpaceCameraPos);
                #ifdef _FOGTYPE_LINEAR
                    float l_FogIntensity = saturate((l_Depth - _FogStartDistance) / (_FogEndDistance - _FogStartDistance));
                #elif _FOGTYPE_EXP
                     float l_FogIntensity = 1.0 - (1.0 / exp(l_Depth*_FogIntensity));
                #else
                     float l_FogIntensity = saturate((l_Depth - _FogStartDistance) / (_FogEndDistance - _FogStartDistance));
                #endif
                
                
                
                return float4(l_heatColor.xyz * (1.0f - l_FogIntensity) + l_FogIntensity * _FogColor.xyz, 1);
}
             ENDCG
         }
    }
}

