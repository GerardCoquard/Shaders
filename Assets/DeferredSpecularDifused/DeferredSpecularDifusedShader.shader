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
            

            float3 Texture2Normal(float3 Texture)
            {
                return (Texture - 0.5) * 2;
            }
            
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
                 //Sacamos propiedades necesarias;
                 //- Color despues de pospos (después del ambient)
                 //- Normales
                 //- Color de la RT0 (color de lo que ve el GBuffer, sin ambient y sin nada)
                 //- Shadowmap
                 //- Depth del objeto en este pixel. Si es 0, quiere decir que no hay nada (depth infinita), asi q devolvemos el color que habia despues de pospo, ya que no hay nada que iluminar
                 //- Dirección de la luz
                 //- Posición de mundo de lo que hay en este pixel. La X y la Y las sabemos gracias a las UVs, la Z es el depth de la RT2
                 float4 l_color = tex2D(_MainTex,i.uv);
                float3 Nn = normalize(Texture2Normal(tex2D(_RT1,i.uv).xyz));
                float4 albedoColor = tex2D(_RT0, i.uv);
                float l_ShadowMap = 0;
                float l_depth = tex2D(_RT2, i.uv).x;
                if(l_depth == 0.0) return l_color;
                float3 l_LightDirection = _LightDirection.xyz;
                float3 _WorldPos = GetPositionFromZDepthView(l_depth,i.uv,_InverseViewMatrix, _InverseProjectionMatrix);
                //Ponemos atenuación a 1 para las directionals
                float l_Attenuation = 1.0;
        
                if (_UseShadowMap==1)
                {
                    float4 l_Vertex = mul(_ShadowMapViewMatrix, float4(_WorldPos, 1.0));
                    l_Vertex= mul(_ShadowMapProjectionMatrix, l_Vertex);
                    float l_Depth = l_Vertex.z / l_Vertex.w;
                    float2 l_UV = float2(((l_Vertex.x / l_Vertex.w) / 2.0f) + 0.5f, ((l_Vertex.y / l_Vertex.w) / 2.0f) + 0.5f);
                    #if SHADER_API_D3D9
                    float l_ShadowMapDepth = ((tex2D(_ShadowMap, l_UV).x-0.5)*2.0)+ _ShadowMapBias;
                    #elif SHADER_API_D3D11
                    float l_ShadowMapDepth = (((1.0 - tex2D(_ShadowMap, l_UV).x)-0.5)*2.0)+ _ShadowMapBias;
                    #else
                    float l_ShadowMapDepth = _ShadowMapBias+tex2D(_ShadowMap, l_UV).x;
                    #endif
                    l_ShadowMap = l_Depth > l_ShadowMapDepth ? (1.0-_ShadowMapStrength) : 1.0;
                    if (l_UV.x <= 0.0 || l_UV.x >= 1.0 || l_UV.y <= 0.0 || l_UV.y >= 1.0)
                      l_ShadowMap = 1.0;
                }
                //Si la luz es point o spot:
                if (_LightType == 2 || _LightType == 0)
                {
                    //Calculamos la direccion normalizada de la luz, y la distancia de la luz hasta la posicion del pixel
                    l_LightDirection = _WorldPos - _LightPosition.xyz;
                    float l_distance = length(l_LightDirection);
                    l_LightDirection/=l_distance; //esto es lo mismo que hacer un normalize
                    //Calculamos la atenuacion, haciendo current/max, en este caso distance/range, i haciendo saturate para que este entre 0 y 1 
                    l_Attenuation =saturate(1 - l_distance / _LightProperties.x);
                    //Si la luz es spot:
                    if (_LightType == 0)
                    {
                        //Calculamos la atenuacion por angulo de la spot, cuando mas al centro mas alta la atenuacion. Esta se aplica encima de la que ya habia en base a la distancia
                        //Miramos cual es el angulo entre la direccion de la luz a la posicion del pixel, y la direccion en la que enfoca la luz
                        float l_DotSpot = dot(_LightDirection.xyz, l_LightDirection);
                        //Calculamos la atenuacion angular, haciendo current/max, en este caso "ni puta idea, lo que ponga", i haciendo saturate para que este entre 0 y 1 
                        float l_AngleAttenuation = saturate((l_DotSpot - _LightProperties.w) / (1.0 - _LightProperties.w));
                        //Luego multiplicamos esta atenuacion angular a la de distancia que ya habia antes, para obtener la final
                        l_Attenuation *= l_AngleAttenuation;
                    }
                }
                //Calculamos Difuse:
                //Kd = cuanto de paralela va la direccion de la luz con la normal del objeto. Si van paralelas, hay mucha difusa. A la que se va inclinando el angulo, cada vez baja mas el Kd, asi que la difusa disminuye
                //Kd es mas alto cuando el angulo entre la normal i la direccion de la luz invertida es 0º, es decir, cuando son paralelos. En cambio, cuando el angulo es de 90º, consigue el Kd mas bajo de 0. Cuando el angulo es mas de 90º, el saturate lo dejara en 0 en vez de -1., 
                float Kd = saturate(dot(Nn, -l_LightDirection));
                float3 l_DifuseLighting = Kd * l_Attenuation * albedoColor.xyz * _LightColor.xyz * _LightProperties.y * l_ShadowMap;//Kd * atenuacion * color del pixel SIN pospo * color luz * intensidad luz * shadowmap?
                //Calculamos Specular:
                //Vector camara-pos_pixel
                float3 l_CameraVector = normalize(_WorldPos - _WorldSpaceCameraPos);
                //Vector reflejado de la cam-posPixel con la normal
                float3 l_ReflectedVector = normalize(reflect(l_CameraVector, Nn));
                 //Ks = cuanto de paralelo es el reflejado de la camara al pixel con la direccion de la luz invertida. Representa cuanto de directo va a la camara el rebote de la luz en ese pixel
                 //Cuanto mas paralelos sean, mas parecido sera el vector reflejado (vector que representa la direccion de rebote directo perfecto en el objeto) a la direccion de la luz invvertida
                 //Puede que aunque la luz no este iluminando ese pixel, el Ks sea muy alto. Eso es debido a que el Ks no tiene en cuenta la posicon, solo la dirección.
                 //Para tener en cuenta si la luz te ilumina o no, se encarga la atenuacion
                float l_Ks = pow(saturate(dot(-_LightDirection.xyz, l_ReflectedVector)), 1/albedoColor.w);
                float3 l_Specular = l_Ks * l_Attenuation * _LightColor.xyz * _LightProperties.y * l_ShadowMap;//Ks * atenuación * color luz * intensidad luz * shadowmap?
                 //Calculamos full light con color CON pospo(con ambient) + specular + difusa
                float3 l_FullLighting = l_color.xyz + l_Specular + l_DifuseLighting;

                return float4(l_FullLighting, 1.0);
             }
             ENDCG
         }
    }
}
