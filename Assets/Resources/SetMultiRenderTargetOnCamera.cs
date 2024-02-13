using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class SetMultiRenderTargetOnCamera : MonoBehaviour
{
	public RenderTexture[] m_RenderTargets;
	RenderBuffer[] m_RenderBuffers;

	void Start()
	{
		InitHotValues();
	}
	void Update()
	{
	}
	void InitHotValues()
	{
		if(m_RenderTargets!=null && m_RenderTargets.Length>0)
		{
			m_RenderBuffers=new RenderBuffer[m_RenderTargets.Length];
			for(int i=0;i<m_RenderTargets.Length;++i)
				m_RenderBuffers[i]=m_RenderTargets[i]!=null ? m_RenderTargets[i].colorBuffer : new RenderBuffer();
		}
		else
			m_RenderBuffers=null;
	}
	void LateUpdate()
	{
#if UNITY_EDITOR
		InitHotValues();
#endif
		//m_RenderTargets[0].colorBuffer
		/*UnityEngine.Rendering.CommandBuffer[] l_CommandBuffer=GetComponent<Camera>().GetCommandBuffers(UnityEngine.Rendering.CameraEvent.BeforeGBuffer);
		for(int i=0;i<l_CommandBuffer.Length;++i)
			Debug.Log("sr "+l_CommandBuffer[i].name);*/
		if(m_RenderTargets!=null && m_RenderTargets.Length>0)
		{
			GetComponent<Camera>().SetTargetBuffers(m_RenderBuffers, m_RenderTargets[0]!=null ? m_RenderTargets[0].depthBuffer : new RenderBuffer());
			/*GetComponent<Camera>().Render();
			GetComponent<Camera>().targetTexture=null;*/
		}
			//Graphics.SetRenderTarget(m_RenderBuffers, m_RenderTargets[0].depthBuffer);
		//GetComponent<Camera>().forceIntoRenderTexture=true;
		//UnityEngine.Rendering.CommandBuffer l_MultiRenderTarget=new UnityEngine.Rendering.CommandBuffer();
		//l_MultiRenderTarget.SetRenderTarget(m_RenderBuffers, m_RenderTargets[0].depthBuffer);
		//GetComponent<Camera>().AddCommandBuffer(UnityEngine.Rendering.CameraEvent.BeforeGBuffer, l_MultiRenderTarget);
		//GetComponent<Camera>().targetTexture=m_RenderTargets[0];
		
		//GetComponent<Camera>().Render();
		
		
    }
	void OnPostRender()
	{
		GetComponent<Camera>().targetTexture=null;
		//GetComponent<Camera>().SetTargetBuffers(null, null);
	}
}
