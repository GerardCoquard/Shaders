Shader "Tecnocampus/DeferredSpecularDefusedShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "defaulttexture"{}
        _RT0("_RT0", 2D) = "defaulttexture"{}
        _RT1("_RT1", 2D) = "defaulttexture"{}
        _RT2("_RT2", 2D) = "defaulttexture"{}
        
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
            sampler2D _RT0;
            sampler2D _RT1;
            sampler2D _RT2;
            sampler2D _MainTex;

            float4 _LightColor;
            float4x4 _InverseViewMatrix;
            float4x4 _InverseProjectionMatrix;
            int _LightType; //0=Spot, 1=Directional, 2=Point
            float4 _LightPosition;
            float4 _LightDirection;
            float4 _LightProperties; // x=Range, y=Intensity,z=Spot Angle, w=cos(Half Spot Angle)
            int _UseShadowMap;
            sampler2D _ShadowMap;
            float4x4 _ShadowMapViewMatrix;
            float4x4 _ShadowMapProjectionMatrix;
            float _ShadowMapBias;
            float _ShadowMapStrength;

            float3 Normal2Texture(float3 _normal)
            {
                return (_normal + 1.0) * 0.5;
            };
            
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
                 //o.vertex = UnityObjectToClipPos(v.vertex); Hace lo que las 3 lineas ultimas a la vez: Local to World, To View, To Projection.
                 //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0)); Same que la de arriba.
                 //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                 o.vertex=mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));                
                 o.vertex=mul(UNITY_MATRIX_V, o.vertex);
                 o.vertex=mul(UNITY_MATRIX_P, o.vertex);

                 

                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex); ESTO ES TILLING, o.uv = v.uv NO ES TILLING, SIMPLE
                 //o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                 o.uv= v.uv;
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                float3 Nn = normalize(Normal2Texture(tex2D(_RT1,i.uv)));
                float4 l_color = tex2D(_RT0, i.uv);
                float3 l_DifuseLighting = float3(0, 0, 0);
                float3 l_Specular = float3(0, 0, 0);
                float3 l_FullLighting = float3(0, 0, 0);

                float3 l_LightDirection = _LightDirection.xyz;
                float3 _WorldPos = GetPositionFromZDepthView(tex2D(_RT2,i.uv),i.uv,_InverseViewMatrix, _InverseProjectionMatrix);
                float l_distance = length(_WorldPos - _LightPosition);
                float l_Attenuation = saturate(1 - l_distance / _LightProperties.x);
        
                if (_LightType == 2)
                {
                    l_LightDirection = normalize(_WorldPos - _LightPosition.xyz);

                }
                if (_LightType == 0)
                {
                    l_LightDirection = normalize(_WorldPos - _LightPosition.xyz);
                        
                    float l_DotSpot = dot(_LightDirection.xyz, l_LightDirection);
                    float l_AngleAttenuation = saturate((l_DotSpot - _LightProperties.w) / (1.0 - _LightProperties.w));
                    l_Attenuation *= l_AngleAttenuation;

                }
                float Kd = saturate(dot(Nn, -l_LightDirection));
        
                l_DifuseLighting += Kd * l_color.xyz * _LightColor.xyz * _LightProperties.y * l_Attenuation;
                    
                    
                /*
                    float3 l_Nn = normalize(i.normal);
                    float3 l_CameraVector = normalize(_WorldSpaceCameraPos);
                    float3 l_Hn = normalize(l_CameraVector - _LightDirections[x].xyz);
                        
                    float3 l_Ks = pow(saturate(dot(l_Hn, l_Nn)), _SpecularPower);
                */
                float3 l_CameraVector = normalize(_WorldPos - _WorldSpaceCameraPos);
                float3 l_ReflectedVector = normalize(reflect(l_CameraVector, Nn));
                float l_Ks = pow(saturate(dot(-_LightDirection.xyz, l_ReflectedVector)), 1/l_color.w);
                
                l_Specular = l_Ks * _LightColor.xyz * l_Attenuation * _LightProperties.y;
                    
                l_FullLighting = l_Specular + l_DifuseLighting;

                return float4(l_FullLighting, 1.0);
             }
             ENDCG
         }
    }
}