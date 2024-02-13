Shader "Tecnocampus/ScratchedShader"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "defaulttexture"{}
        _Noise("Noise", 2D) = "defaulttexture"{}
        _ScratchThreshold("Threshold", Range(0.0,1.0)) = 0.5
        _Speed("Speed", Range(0.0,1.0)) = 0.01
        _ScratchIntensity("Intensity", Float) = 1
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
                float2 NoiseUV : TEXCOORD1;

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 NoiseUV : TEXCOORD1;
            };
            sampler2D _Noise;
            float4 _Noise_ST;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScratchThreshold;
            float _Speed;
            float _ScratchIntensity;

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
               
                 
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex); ESTO ES TILLING, o.uv = v.uv NO ES TILLING, SIMPLE
                 //o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                 o.uv= v.uv;
                 o.NoiseUV = TRANSFORM_TEX(v.uv, _Noise);
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float4 l_Color=tex2D(_MainTex,i.uv);
                 float l_Scratch=tex2D(_Noise, float2(i.NoiseUV.x, _Time.y*_Speed)).x;
                 l_Scratch = l_Scratch>_ScratchThreshold ? (l_Scratch-_ScratchThreshold)/(1.0- _ScratchThreshold) : 0;
                 return l_Color-float4(l_Scratch.xxx,0)*_ScratchIntensity;
             }
             ENDCG
         }
    }
}
