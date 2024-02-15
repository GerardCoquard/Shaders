using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DeferredLightPostProcessing : MonoBehaviour
{
	public Material m_Material;
	public List<Light> m_Lights;
	RenderTexture[] m_BufferedRenderTextures;
	Camera m_Camera;

	void Start()
	{
		InitHotValues(Screen.width, Screen.height);
	}
	void InitHotValues(int Width, int Height)
	{
		if(m_Camera==null)
			m_Camera=GetComponent<Camera>();

		if(m_BufferedRenderTextures==null || m_BufferedRenderTextures.Length!=2 || m_BufferedRenderTextures[0].width!=Width || m_BufferedRenderTextures[0].height!=Height)
		{
			m_BufferedRenderTextures=new RenderTexture[2];
			m_BufferedRenderTextures[0]=new RenderTexture(Width, Height, 0);
			m_BufferedRenderTextures[1]=new RenderTexture(Width, Height, 0);
		}
	}
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if(m_Material==null)
			return;

#if UNITY_EDITOR
		InitHotValues(src.width, src.height);
#endif
		if(m_Lights.Count==0)
		{
			m_Material.SetColor("_LightColor", Color.black);
			Graphics.Blit(src, dest, m_Material);
		}
		else
		{
			RenderTexture l_Dest=dest;
			RenderTexture l_Source=src;
			Matrix4x4 l_InverseViewMatrix=m_Camera.worldToCameraMatrix;
			l_InverseViewMatrix=l_InverseViewMatrix.inverse;
			Matrix4x4 l_InverseProjectionMatrix=m_Camera.projectionMatrix;
			l_InverseProjectionMatrix=l_InverseProjectionMatrix.inverse;

			Shader.SetGlobalMatrix("_InverseViewMatrix", l_InverseViewMatrix);
			Shader.SetGlobalMatrix("_InverseProjectionMatrix", l_InverseProjectionMatrix);

			for(int i=0;i<m_Lights.Count;++i)
			{
				Light l_Light=m_Lights[i];
				
				m_Material.SetColor("_LightColor", l_Light.color);
				m_Material.SetInt("_LightType", (int)l_Light.type);
				Vector4 l_Position=l_Light.transform.position;
				m_Material.SetVector("_LightPosition", l_Position);
				Vector4 l_Direction=Vector4.zero;
				if(l_Light.type==LightType.Directional || l_Light.type==LightType.Spot)
					l_Direction=l_Light.transform.forward;
				m_Material.SetVector("_LightDirection", l_Direction);
				Vector4 l_LightProperties=new Vector4(l_Light.range, l_Light.intensity, l_Light.spotAngle*Mathf.Deg2Rad, Mathf.Cos(l_Light.spotAngle*Mathf.Deg2Rad*0.5f));
				m_Material.SetVector("_LightProperties", l_LightProperties);

				Texture l_ShadowMap=null;
				GenerateShadowMap l_GenerateShadowMap=l_Light.GetComponent<GenerateShadowMap>();
				if(l_GenerateShadowMap!=null && l_GenerateShadowMap.enabled && l_GenerateShadowMap.IsValidLight())
				{
					l_ShadowMap=l_GenerateShadowMap.m_ShadowMap;
					m_Material.SetTexture("_ShadowMap", l_ShadowMap);
					m_Material.SetMatrix("_ShadowMapViewMatrix", l_GenerateShadowMap.GetViewMatrix());
					m_Material.SetMatrix("_ShadowMapProjectionMatrix", l_GenerateShadowMap.GetProjectionMatrix());
					m_Material.SetFloat("_ShadowMapBias", l_GenerateShadowMap.m_ShadowMapBias);
					m_Material.SetFloat("_ShadowMapStrength", l_GenerateShadowMap.m_ShadowMapStrength);
				}
				m_Material.SetInt("_UseShadowMap", l_ShadowMap!=null ? 1 : 0);
				
				l_Dest=(m_Lights.Count-1)==i ? dest : m_BufferedRenderTextures[(i%2==0) ? 0 : 1];
				Graphics.Blit(l_Source, l_Dest, m_Material);
				l_Source=m_BufferedRenderTextures[(i%2==0) ? 0 : 1];
			}
		}
    }
}
