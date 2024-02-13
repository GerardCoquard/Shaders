using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class SetCameraVectorsOnMaterial : MonoBehaviour
{
	MeshRenderer m_MeshRenderer;
	void Start()
	{
		m_MeshRenderer=GetComponent<MeshRenderer>();
	}
	void LateUpdate()
	{
		Vector4 l_RightDirection=Camera.main.transform.right;
		Vector4 l_UpDirection=Camera.main.transform.up;
		if(m_MeshRenderer.sharedMaterial!=null)
		{
			m_MeshRenderer.sharedMaterial.SetVector("_RightDirection", l_RightDirection);
			m_MeshRenderer.sharedMaterial.SetVector("_UpDirection", l_UpDirection);
		}
	}
}
