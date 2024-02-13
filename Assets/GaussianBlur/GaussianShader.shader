Shader "Tecnocampus/GaussianShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        _SampleDistance("Distance", Float) = 1
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
            float _SampleDistance;


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
                 o.uv= v.uv;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float2 l_KernelBase[7] =
                {
	                { 0.0,  0.0 },
	                { 1.0,  0.0 },
	                { 0.5,  0.8660 },
	                { -0.5,  0.8660 },
	                { -1.0,  0.0 },
	                { -0.5, -0.8660 },
	                { 0.5, -0.8660 },
                };
                float l_KernelWeights[7] =
                {
	                0.38774,
	                0.06136,
	                0.24477 / 2.0,
	                0.24477 / 2.0,
	                0.06136,
	                0.24477 / 2.0,
	                0.24477 / 2.0,
                };
                 float3 l_Color = float3(0,0,0);
                 
                 for (int j = 0; j < l_KernelWeights.Length; j++)
                 {
                    float2 l_UVScaled = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y)*_SampleDistance;
                    l_Color += tex2D(_MainTex, i.uv + l_UVScaled*l_KernelBase[j]).xyz*l_KernelWeights[j];
                 }
                 return float4(l_Color.xyz,1);
             }
             ENDCG
         }
    }
}
