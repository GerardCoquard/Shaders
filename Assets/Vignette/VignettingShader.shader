Shader"Tecnocampus/VignettingShader"
{
Properties
{
    _MainTex("MainTexture", 2D) = "defaulttexture" {}
    _Vignetting("Vignetting", Range(0.0,1.0)) = 0.5
    _VignettingColor("VignettingColor", Color) = (0,0,0,1)
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

            struct appdata
            {
                 float4 vertex : POSITION;
                 float3 normal : NORMAL;
                 float2 uv : TEXCOORD0;
};
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
};
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float4 _VignettingColor;
                float _Vignetting;
            v2f vert(appdata v)
            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex); //Lo mismo que las operaciones de abajo
                //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
                //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //De local a mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //De mundo a view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //De view a proyección
                o.normal = mul((float3x3) unity_ObjectToWorld, v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
   
                 
             return o;
            }

            


            fixed4 frag(v2f i) : SV_Target
            {
                float4 l_color = tex2D(_MainTex, i.uv);
                float l_Length = length(i.uv - float2(0.5, 0.5));
                float l_StartVignetting = _Vignetting;
                float l_EndVignetting = _Vignetting + 0.5 * _Vignetting;
                float l_VignettingPct = saturate((l_Length - l_StartVignetting) / (l_EndVignetting - l_StartVignetting));
                
                    return float4(l_color.xyz * (1 - l_VignettingPct), 1);
}
             ENDCG
         }
    }
}

