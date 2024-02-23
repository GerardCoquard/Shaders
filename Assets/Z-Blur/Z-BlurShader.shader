Shader "Tecnocampus/Z-BlurShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _DepthTex("Depth", 2D) = "white" {}
        _SampleDistance("Sample distance", Range(1, 20.0)) = 1.0
        _ZMinFocusDistance("Z min focus distance", float) = 3.0
        _ZMaxFocusDistance("Z max focus distance", float) = 3.0
        _ZMaxUnfocusDistance("Z max unfocus distance", float) = 5.0
        _MinZBlurPct("Min ZBlur Pct", Range(0.0, 1.0)) = 0.0
        _ShowDebug("Show debug", float) = 0.0
        _SampleDistance("Distance", Float) = 1
        [KeywordEnum(Focused, Debug, Unfocused, Default)] _Mode("Mode", int) = 0
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

            #pragma shader_feature_MODE_FOCUSED_MODE_DEBUG_MODE_UNFOCUSED_MODE_DEFAULT

            #include "UnityCG.cginc"

            struct VERTEX_IN
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 depth : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DepthTex;
            float4 _DepthTex_ST;
            float _SampleDistance; 
            float _ZMinFocusDistance;
            float _ZMaxFocusDistance;
            float _ZMaxUnfocusDistance; 
            float _MinZBlurPct; 
            float _ShowDebug; 
            float4x4 _InverseViewMatrix;
            float4x4 _InverseProjectionMatrix;


            

            float3 GetPositionFromZDepthViewInViewCoordinates(float ZDepthView, float2 UV, float4x4 InverseProjection)
            {
                // Get the depth value for this pixel
                // Get x/w and y/w from the viewport position
                //Depending on viewport type
                float x = UV.x * 2 - 1;
                float y = UV.y * 2 - 1;
                #if SHADER_API_D3D9
                float4 l_ProjectedPos = float4(x, y, ZDepthView*2.0 - 1.0, 1.0);
                #elif SHADER_API_D3D11
                float4 l_ProjectedPos = float4(x, y, (1.0-ZDepthView)*2.0 - 1.0, 1.0);
                #else
                float4 l_ProjectedPos = float4(x, y, ZDepthView, 1.0);
                #endif
                // Transform by the inverse projection matrix
                float4 l_PositionVS=mul(InverseProjection, l_ProjectedPos);
                // Divide by w to get the view-space position
                return l_PositionVS.xyz/l_PositionVS.w;
            };
            float3 GetPositionFromZDepthView(float ZDepthView, float2 UV, float4x4 InverseView, float4x4 InverseProjection)
            {
                float3 l_PositionView=GetPositionFromZDepthViewInViewCoordinates(ZDepthView, UV, InverseProjection);
                return mul(InverseView, float4(l_PositionView, 1.0)).xyz;
            };

            VERTEX_OUT vert (VERTEX_IN v)
             {
                 VERTEX_OUT o;
                 
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);
                 
                 o.uv = v.uv;
                 o.depth = o.vertex.zw;

                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                float4 l_FocusedColor = tex2D(_MainTex,i.uv);
                float3 l_UnfocusedColor = float3(0,0,0);
                float l_depth = tex2D(_DepthTex, i.uv).x;
                if(l_depth == 0.0) return l_FocusedColor;
                float3 _WorldPos = GetPositionFromZDepthView(l_depth,i.uv,_InverseViewMatrix, _InverseProjectionMatrix);
                float l_Distance = length(_WorldPos.xyz-_WorldSpaceCameraPos.xyz);
                float4 l_DebugColor = float4(1,0,0,1);
                float l_ZBlurPct = 0.0;

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
                float3 l_color = float3(0,0,0);

                for (int j = 0; j < l_KernelWeights.Length; j++)
                {
                float2 l_UVScaled = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y)*_SampleDistance;
                l_UnfocusedColor += tex2D(_MainTex, i.uv + l_UVScaled*l_KernelBase[j]).xyz*l_KernelWeights[j];
                }


                if (l_Distance < _ZMinFocusDistance)
                {
                    l_DebugColor = float4(1, 0, 0, 1);
                    l_ZBlurPct = _MinZBlurPct;
                }
                else if (l_Distance < _ZMaxFocusDistance)
                {
                    l_ZBlurPct = 0.0;
                    l_DebugColor = float4(0, 1, 0, 1);
                }
                else
                {
                    l_ZBlurPct = saturate((l_Distance-_ZMaxFocusDistance)/(_ZMaxUnfocusDistance -_ZMaxFocusDistance));
                    l_DebugColor = float4(0, 0, 1, 1);
                }

                #ifdef _MODE_FOCUSED
                    return l_FocusedColor;
                #elif _MODE_UNFOCUSED
                    return float4(l_UnfocusedColor,1);
                #elif _MODE_DEBUG
                    return l_DebugColor;
                #elif _MODE_DEFAULT
                    return float4(l_FocusedColor.xyz*(1.0 - l_ZBlurPct) + l_UnfocusedColor.xyz*l_ZBlurPct,1.0);
                #endif

                return l_DebugColor;
             }
             ENDCG
         }
    }
}
