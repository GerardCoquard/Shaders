using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostProcessing : MonoBehaviour
{
	public Material m_Material;
	RenderTexture m_RenderTexture;
	public bool m_UseRenderToTexture=false;
	public bool m_WidthSameAsFrameBuffer=true;
	protected Camera m_Camera;
	public bool m_UseMipMap=false;
	[System.Serializable]
	public class CMaterialTexture
	{
		public string m_TextureName;
		public PostProcessing m_PostProcessing;
	}
	public List<CMaterialTexture> m_MaterialTextures;

	protected virtual void Start()
	{
		InitHotValues();
	}
	protected virtual void InitHotValues()
	{
		if(m_Camera==null)
			m_Camera=GetComponent<Camera>();
		if(m_UseRenderToTexture)
		{
			m_RenderTexture=new RenderTexture(m_WidthSameAsFrameBuffer ? Screen.width : 256, m_WidthSameAsFrameBuffer ? Screen.height : 256, 0);
		}
	}
	protected virtual void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
#if UNITY_EDITOR
		InitHotValues();
#endif
		if(m_Material==null)
			return;
		foreach(CMaterialTexture l_MaterialTexture in m_MaterialTextures)
		{
			if(l_MaterialTexture.m_PostProcessing!=null)
			{
				m_Material.SetTexture(l_MaterialTexture.m_TextureName, l_MaterialTexture.m_PostProcessing.m_RenderTexture);
			}
		}
		if(m_UseRenderToTexture)
			m_RenderTexture.useMipMap=m_UseMipMap;
		Graphics.Blit(src, m_UseRenderToTexture ? m_RenderTexture : dest, m_Material);
    }
}
