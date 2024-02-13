Shader "Tecnocampus/PBRLightingShader"
{
	Properties
	{
		_AmbientColor("_AmbientColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_EnivronmentTex("_EnivronmentTex", CUBE) = "" {}
		_AmbientIntensity("_AmbientIntensity", Range(0.0, 2.0)) = 0.5
		_MainTex("_MainTex", 2D) = "defaulttexture" {}
		_Roughness("_Roughness", Range(0.0, 1.0)) = 0.5
		_FresnelR0("_FresnelR0", Range(0.0, 1.0)) = 0.2
		_Metallic("_Metallic", Range(0.0, 1.0)) = 0.0
		_AmbientReflectionsIntensity("_AmbientReflectionsIntensity", Range(0.0, 1.0)) = 0.5
		[KeywordEnum(Implicit, Neumann, Kelemen)] _GeometryType("_GeometryType", Float) = 0
		[KeywordEnum(Blinn, Beckmann, GGX)] _DistributionType("_DistributionType", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			//Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#pragma multi_compile _GEOMETRYTYPE_IMPLICIT _GEOMETRYTYPE_NEUMANN _GEOMETRYTYPE_KELEMEN
			#pragma multi_compile _DISTRIBUTIONTYPE_BLINN _DISTRIBUTIONTYPE_BECKMANN _DISTRIBUTIONTYPE_GGX

			struct VERTEX_IN
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			struct VERTEX_OUT
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 WorldPosition : TEXCOORD1;
			};

#define MAX_LIGHTS 		4
#define _PI 3.14159274


			int _LightsCount;
			int _LightTypes[MAX_LIGHTS];//0=Spot, 1=Directional, 2=Point
			float4 _LightColors[MAX_LIGHTS];
			float4 _LightPositions[MAX_LIGHTS];
			float4 _LightDirections[MAX_LIGHTS];
			float4 _LightProperties[MAX_LIGHTS]; //x=Range, y=Intensity, z=Spot Angle, w=cos(Half Spot Angle)
			float _Roughness;

			float4 _AmbientColor;
			float _AmbientIntensity;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			samplerCUBE _EnivronmentTex;
			float _FresnelR0;
			float _Metallic;
			float _AmbientReflectionsIntensity;

			VERTEX_OUT vert(VERTEX_IN v)
			{
				VERTEX_OUT o;
				o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
				o.WorldPosition = o.vertex;
				o.vertex = mul(UNITY_MATRIX_V, o.vertex);
				o.vertex = mul(UNITY_MATRIX_P, o.vertex);
				o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			float FresnelSchlick(float3 LightDirection, float3 Nn)
			{
				return (_FresnelR0 + (1.0 - _FresnelR0)*pow((1.0 - max(0.0, dot(Nn, -LightDirection))), 5));
			}
			float GeometryImplicit(float3 Nn, float3 LightDirection, float3 Vn)
			{
				return dot(Nn, -LightDirection)*dot(Nn, -Vn);
			}
			float GeometryNeumann(float3 Nn, float3 LightDirection, float3 Vn)
			{
				return (dot(Nn, -LightDirection)*dot(Nn, -Vn)) / max(dot(Nn, -LightDirection), dot(Nn, -Vn));
			}
			float GeometryKelemen(float3 Nn, float3 LightDirection, float3 Vn, float3 Hn)
			{
				return (dot(Nn, -LightDirection)*dot(Nn, -Vn)) / pow(dot(-Vn, Hn), 2);
			}
			float DistributionBlinn(float Roughness, float3 Nn, float3 h)
			{
				float l_Roughness2 = Roughness * Roughness;
				return (1.0 / (_PI*l_Roughness2))*pow(dot(Nn, h), ((2.0 / l_Roughness2) - 2.0));
			}
			float DistributionBeckmann(float Roughness, float3 Nn, float3 Hn)
			{
				float l_Roughness2 = Roughness * Roughness;
				float l_DotNH = dot(Nn, Hn);
				float l_DotNH2 = l_DotNH * l_DotNH;
				float l_DotNH4 = l_DotNH2 * l_DotNH2;
				return saturate((1.0 / (_PI*l_Roughness2*l_DotNH4))*exp((l_DotNH2 - 1.0) / (l_Roughness2*l_DotNH2)));
			}
			float DistributionGGX(float Roughness, float3 Nn, float3 Hn)
			{
				float l_Roughness2 = Roughness * Roughness;
				float l_DotNH = dot(Nn, Hn);
				float l_Denominator = (l_DotNH*l_DotNH*(l_Roughness2 - 1.0)) + 1.0;
				return l_Roughness2 / (_PI*l_Denominator*l_Denominator);
			}
			float3 CalcAmbientLighting(float3 AlbedoColor, float3 Vn, float3 Nn)
			{
				float3 l_ReflectedVector = reflect(Vn, Nn);
				float l_Fresnel = FresnelSchlick(Vn, Nn);
				float3 l_AmbientColor = AlbedoColor * texCUBE(_EnivronmentTex, float3(0, 0, 0)).xyz*_AmbientIntensity;
				float3 l_AmbientReflectionsColor = texCUBElod(_EnivronmentTex, float4(l_ReflectedVector, _Roughness*9.0)).xyz*_AmbientReflectionsIntensity;
				float3 l_AmbientReflections = l_AmbientReflectionsColor * l_Fresnel;
				return lerp(l_AmbientReflections + l_AmbientColor, l_AmbientReflectionsColor*AlbedoColor + l_AmbientReflections, _Metallic);
			}
			float BRDFSpecular(float3 LightDirection, float3 Nn, float3 Vn, float3 Hn)
			{
				float l_Fresnel = FresnelSchlick(LightDirection, Nn);
#ifdef _GEOMETRYTYPE_IMPLICIT
				float l_Geometry = GeometryImplicit(Nn, LightDirection, Vn);
#elif _GEOMETRYTYPE_NEUMANN
				float l_Geometry = GeometryNeumann(Nn, LightDirection, Vn);
#else //_GEOMETRYTYPE_KELEMEN
				float l_Geometry = GeometryKelemen(Nn, LightDirection, Vn, Hn);
#endif
#ifdef _DISTRIBUTIONTYPE_BLINN 
				float l_Distribution = DistributionBlinn(_Roughness, Nn, Hn);
#elif _DISTRIBUTIONTYPE_BECKMANN 
				float l_Distribution = DistributionBeckmann(_Roughness, Nn, Hn);
#else //_DISTRIBUTIONTYPE_GGX
				float l_Distribution = DistributionGGX(_Roughness, Nn, Hn);
#endif
				float l_DotNL = dot(Nn, -LightDirection);
				float l_DotNV = dot(Nn, -Vn);
				return saturate((l_Fresnel*l_Geometry*l_Distribution) / (4.0*l_DotNL*l_DotNV));
			}
			fixed4 frag(VERTEX_OUT IN) : SV_Target
			{
				float3 Nn = normalize(IN.normal);
				float4 l_Color = tex2D(_MainTex, IN.uv);
				float3 l_SpecularLighting = float3(0, 0, 0);
				float3 l_DifuseLighting = float3(0, 0, 0);
				float3 Vn = normalize(IN.WorldPosition- _WorldSpaceCameraPos.xyz);
				
				float3 l_AmbientLighting = CalcAmbientLighting(l_Color.xyz, Vn, Nn);//l_Color.xyz*_AmbientColor.xyz*_AmbientIntensity;
				for (int i = 0; i < _LightsCount; ++i)
				{
					float3 l_LightDirection = _LightDirections[i];
					float l_Attenuation = 1.0;
					if (_LightTypes[i]==0 || _LightTypes[i] == 2)
					{
						float3 l_LightDirectionNotNormalized=IN.WorldPosition - _LightPositions[i];
						float l_DistanceToPixel = length(l_LightDirectionNotNormalized);
						l_LightDirection = l_LightDirectionNotNormalized / l_DistanceToPixel;
						l_Attenuation = saturate(1.0 - l_DistanceToPixel / _LightProperties[i].x);
						if (_LightTypes[i] == 0)
						{
							float l_SpotAngle = dot(l_LightDirection, _LightDirections[i].xyz);
							float l_AngleAttenuation = saturate((l_SpotAngle-_LightProperties[i].w) / (1.0 - _LightProperties[i].w));
							l_Attenuation *= l_AngleAttenuation;
						}
					}
					float3 Kd = saturate(dot(Nn, -l_LightDirection))*(1.0-_Metallic);
					float3 Hn = normalize(-Vn - l_LightDirection);
					l_DifuseLighting += Kd * l_Color.xyz*_LightColors[i] * _LightProperties[i].y*l_Attenuation;
					float l_Fresnel = FresnelSchlick(l_LightDirection, Nn);

					l_SpecularLighting += BRDFSpecular(l_LightDirection, Nn, Vn, Hn)* _LightColors[i] * _LightProperties[i].y*l_Attenuation;

				}
				return float4(l_AmbientLighting + l_DifuseLighting + l_SpecularLighting, l_Color.a);
			}
			ENDCG
		}
	}
}