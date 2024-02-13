Shader "Tecnocampus/LambertShader"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "defaulttexture"{}
        _Attenuation("Attenuation", Range(0.0,2.0)) = 1
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
            #define MAX_LIGHTS 		4


            #include "UnityCG.cginc"

            struct VERTEX_IN
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 WorldPosition : TEXCOORD1;

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
            float4 _AmbientColor;
            float _Attenuation;
            int _LightsCount;
            int _LightTypes[MAX_LIGHTS ];//0=Spot, 1=Directional, 2=Point
            float4 _LightColors[MAX_LIGHTS ];
            float4 _LightPositions[MAX_LIGHTS ];
            float4 _LightDirections[MAX_LIGHTS ];
            float4 _LightProperties[MAX_LIGHTS ]; //x=Range, y=Intensity, z=Spot Angle, w=cos(Half Spot Angle)

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
                 //o.uv=TRANSFORM_TEX(v.uv, _MainTex); ESTO ES TILLING, o.uv = v.uv NO ES TILLING, SIMPLE
                 //o.uv= v.uv + _MainTex_ST.xy + _MainTex_ST.zw;
                 o.uv= TRANSFORM_TEX(v.uv, _MainTex);
                return o;
             }

             fixed4 frag (VERTEX_OUT i) : SV_Target
             {
                 float3 normalized = normalize(i.normal);
                 float4 l_color = tex2D(_MainTex,i.uv);
                 float3 l_DifuseLightning = float3(0,0,0);
                 for (int j = 0; j < _LightsCount; j++)
                 {
                     if(_LightTypes[j] == 0)
                     {
                         float3 l_DirectionLight = normalize(i.WorldPosition - _LightPositions[j].xyz);
                         float dp = length(i.WorldPosition - _LightPositions[j].xyz);
                         float l_LightAttenuation = saturate(1- dp/_LightProperties[j].x);
                         float l_SpotAngle = dot(_LightDirections[j].xyz, l_DirectionLight);
                         float new_l_SpotAngle = saturate((l_SpotAngle-_LightProperties[j].w)/(1.0 - _LightProperties[j].w));

                         l_LightAttenuation*=new_l_SpotAngle;

                         l_DifuseLightning+=l_color.xyz*_LightColors[j].xyz*_LightProperties[j].y*l_LightAttenuation*l_SpotAngle;

                     }
                     if(_LightTypes[j] == 1)
                     {
                         l_DifuseLightning+=l_color.xyz*_LightColors[j].xyz*_LightProperties[j].y*_Attenuation*saturate(dot(normalized,-_LightDirections[j]));
                     }
                     if(_LightTypes[j] == 2)
                     {
                         float3 l_DirectionLight = normalize(i.WorldPosition-_LightPositions[j].xyz);
                         float l_DiffuseContrib = saturate(dot(normalized, -l_DirectionLight));
                          float dp = length(i.WorldPosition - _LightPositions[j].xyz);
                         float l_LightAttenuation = saturate(1- dp/_LightProperties[j].x);
                         float l_SpotAngle = dot(_LightDirections[j].xyz, l_DirectionLight);
                         float new_l_SpotAngle = saturate((l_SpotAngle-_LightProperties[j].w)/(1.0 - _LightProperties[j].w));

                         l_LightAttenuation*=new_l_SpotAngle;
                         l_DifuseLightning+=l_color.xyz*_LightColors[j].xyz*_LightProperties[j].y*l_LightAttenuation*l_DiffuseContrib;
                     }
                     
                 }
                 return float4(l_DifuseLightning, l_color.a);
             
             }
             
             ENDCG
         }
    }
}
