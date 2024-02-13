Shader"Tecnocampus/SpecularShader"
{
Properties
{
    _SpecularPower("_SpecularPower", Float) = 0
    _MainTex("MainTexture", 2D) = "defaulttexture" {}
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
            #define MAX_LIGHTS 4

            #include "UnityCG.cginc"

            struct appdata
            {
                 float4 vertex : POSITION;
                 float3 normal : NORMAL;
                 float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
};
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
};              
                float _SpecularPower;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                int _LightsCount;
                int _LightTypes[ MAX_LIGHTS ]; //0=Spot, 1=Directional, 2=Point
                float4 _LightColors[ MAX_LIGHTS ];
                float4 _LightPositions[ MAX_LIGHTS ];
                float4 _LightDirections[ MAX_LIGHTS ];
                float4 _LightProperties[ MAX_LIGHTS ]; //x=Range, y=Intensity, z=Spot Angle, w=cos(Half Spot Angle)

            v2f vert(appdata v)
            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex); //Lo mismo que las operaciones de abajo
                //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
                //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //De local a mundo
                o.worldPos = o.vertex;
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //De mundo a view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //De view a proyección
                o.normal = mul((float3x3) unity_ObjectToWorld, v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
   
                 
             return o;
            }

            


            fixed4 frag(v2f i) : SV_Target
            {
                float3 Nn = normalize(i.normal);
                float4 l_color = tex2D(_MainTex, i.uv);
                float3 l_DifuseLighting = float3(0, 0, 0);
                float3 l_Specular = float3(0, 0, 0);

                 for (int x = 0; x < _LightsCount; x++)
                 {
                    float3 l_LightDirection = _LightDirections[x].xyz;
                    
                    float l_distance = length(i.worldPos - _LightPositions[x].xyz);
                    float l_Attenuation = saturate(1 - l_distance / _LightProperties[x].x);
        
                    if (_LightTypes[x] == 2)
                    {
                        l_LightDirection = normalize(i.worldPos - _LightPositions[x].xyz);

                    }
                    if (_LightTypes[x] == 0)
                    {
                        l_LightDirection = normalize(i.worldPos - _LightPositions[x].xyz);
                        
                        float l_DotSpot = dot(_LightDirections[x].xyz, l_LightDirection);
                        float l_AngleAttenuation = saturate((l_DotSpot - _LightProperties[x].w) / (1.0 - _LightProperties[x].w));
                        l_Attenuation *= l_AngleAttenuation;

                    }
                    float Kd = saturate(dot(Nn, -l_LightDirection));
        
                    l_DifuseLighting += Kd * l_color.xyz * _LightColors[x].xyz * _LightProperties[x].y * l_Attenuation;
                    
                    
                    /*
                        float3 l_Nn = normalize(i.normal);
                        float3 l_CameraVector = normalize(_WorldSpaceCameraPos);
                        float3 l_Hn = normalize(l_CameraVector - _LightDirections[x].xyz);
                        
                        float3 l_Ks = pow(saturate(dot(l_Hn, l_Nn)), _SpecularPower);
                    */
                    float3 l_CameraVector = normalize(i.worldPos - _WorldSpaceCameraPos);
                    float3 l_ReflectedVector = normalize(reflect(l_CameraVector, normalize(i.normal)));
                    float l_Ks = pow(saturate(dot(-_LightDirections[x].xyz, l_ReflectedVector)), _SpecularPower);
                
                    l_Specular = l_Ks * _LightColors[x].xyz * l_Attenuation * _LightProperties[x].y;
    }
                return float4(l_Specular, l_color.a);
                
}
             ENDCG
         }
    }
}

