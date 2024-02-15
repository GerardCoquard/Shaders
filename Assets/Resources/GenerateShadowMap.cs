using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera), typeof(Light))]
public class GenerateShadowMap : MonoBehaviour
{
	public List<MeshRenderer> m_MeshRenderers;
	List<List<Material>> m_MaterialsPerRenderers;
	public RenderTexture m_ShadowMap;
	public Material m_ShadowMapMaterial;
	Camera m_Camera;
	[Range(0.0f, 0.1f)]
	public float m_ShadowMapBias;
	[Range(0.0f, 1.0f)]
	public float m_ShadowMapStrength;
	Light m_Light;

	void Awake()
	{
		InitHotValues();
	}
	void InitHotValues()
	{
		m_Camera=GetComponent<Camera>();
		m_Camera.enabled=true;
		m_Light=GetComponent<Light>();
	}
	void Start()
	{
	}
	public bool IsValidLight()
	{
		return m_Light.type==LightType.Directional || m_Light.type==LightType.Spot;
	}
	void OnPreRender()
	{
#if UNITY_EDITOR
		InitHotValues();
#endif
		if(!IsValidLight())
			return;

		if(m_ShadowMap==null)
		{
			m_ShadowMap=new RenderTexture(1024, 1024, 24);
			Debug.Log("you must set a shadowmap with type R Float");
		}
		
		if(m_Light.type==LightType.Spot)
		{
			m_Camera.aspect=1.0f;
			m_Camera.fieldOfView=m_Light.spotAngle;
			m_Camera.orthographic=false;
		}
		else
			m_Camera.orthographic=true;
		m_Camera.targetTexture=m_ShadowMap;
		m_MaterialsPerRenderers=new List<List<Material>>();
		foreach(MeshRenderer l_MeshRenderer in m_MeshRenderers)
		{
			List<Material> l_Materials=new List<Material>(l_MeshRenderer.sharedMaterials.Length);
			List<Material> l_ShadowMapMaterials=new List<Material>(l_MeshRenderer.sharedMaterials.Length);
			
			foreach(Material l_Material in l_MeshRenderer.sharedMaterials)
			{
				l_Materials.Add(l_Material);
				l_ShadowMapMaterials.Add(m_ShadowMapMaterial);
			}
			l_MeshRenderer.sharedMaterials=l_ShadowMapMaterials.ToArray();
			m_MaterialsPerRenderers.Add(l_Materials);
		}
	}
	void OnPostRender()
	{
		if(!IsValidLight())
			return;

		for(int i=0;i<m_MeshRenderers.Count;++i)
		{
			List<Material> l_Materials=new List<Material>(m_MeshRenderers[i].sharedMaterials.Length);
			
			foreach(Material l_Material in m_MaterialsPerRenderers[i])
				l_Materials.Add(l_Material);

			m_MeshRenderers[i].sharedMaterials=l_Materials.ToArray();
		}
	}
	public Matrix4x4 GetViewMatrix()
	{
		return m_Camera.worldToCameraMatrix;
	}
	public Matrix4x4 GetProjectionMatrix()
	{
		return m_Camera.projectionMatrix;
	}
}
