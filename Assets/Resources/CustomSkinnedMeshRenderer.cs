using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//How to use it?
//We must create an empty game object on the game object parent of the SkinnedMeshRenderer
//We reset the transform of the new game object
//We add a MeshFilter and MeshRenderer component to the new game object
//We set the same mesh as the SkinnedMeshRenderer mesh to the MeshFilter
//We set as many materials to the new MeshRenderer as the SkinnedMeshRenderer with the SkinningShader
//We add the CustomSkinnedMeshRenderer component to our new game object
//We set the SkinnedMeshRenderer property of the CustomSkinnedMeshRenderer to the SkinnedMeshRenderer game object in order to get the bones and skeleton info
//We hide the SkinnedMeshRenderer game object

[ExecuteInEditMode]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class CustomSkinnedMeshRenderer : MonoBehaviour
{
	public SkinnedMeshRenderer m_SkinnedMeshRenderer;
	MeshFilter m_MeshFilter;
	MeshRenderer m_MeshRenderer;
	Matrix4x4[] m_BoneMatrixs;
	Matrix4x4[] m_BindPosesMatrixs;
	const int m_MaxBones=29;

	void Start()
	{
		m_MeshFilter=GetComponent<MeshFilter>();
		m_MeshRenderer=GetComponent<MeshRenderer>();
		InitVertexData();
	}
	void InitVertexData()
	{
		m_BindPosesMatrixs=m_MeshFilter.sharedMesh.bindposes;

		List<Vector4> l_BlendWeights=new List<Vector4>();
		List<Vector4> l_BlendIndices=new List<Vector4>();
		
		for(int i=0;i<m_MeshFilter.sharedMesh.boneWeights.Length;++i)
		{
			BoneWeight l_BoneWeight=m_MeshFilter.sharedMesh.boneWeights[i];
			l_BlendWeights.Add(new Vector4(l_BoneWeight.weight0, l_BoneWeight.weight1, l_BoneWeight.weight2, l_BoneWeight.weight3));
			l_BlendIndices.Add(new Vector4(l_BoneWeight.boneIndex0, l_BoneWeight.boneIndex1, l_BoneWeight.boneIndex2, l_BoneWeight.boneIndex3));
		}
		m_MeshFilter.sharedMesh.SetUVs(1, l_BlendWeights);
		m_MeshFilter.sharedMesh.SetUVs(2, l_BlendIndices);
		
		m_BindPosesMatrixs=m_MeshFilter.sharedMesh.bindposes;
	}
	void LateUpdate()
	{
		if(m_BoneMatrixs==null || m_BoneMatrixs.Length!=m_SkinnedMeshRenderer.bones.Length)
			m_BoneMatrixs=new Matrix4x4[m_MaxBones];
		Matrix4x4 l_InvertWorld=transform.localToWorldMatrix.inverse;
		for(int i=0;i<m_SkinnedMeshRenderer.bones.Length;++i)
		{
			Transform l_Bone=m_SkinnedMeshRenderer.bones[i];
			
			m_BoneMatrixs[i]=Matrix4x4.TRS(l_Bone.position, l_Bone.rotation, Vector3.one);
			m_BoneMatrixs[i]=l_InvertWorld*m_BoneMatrixs[i]*m_BindPosesMatrixs[i];
		}

		m_MeshRenderer.sharedMaterial.SetMatrixArray("g_Bones", m_BoneMatrixs);
		for(int i=0;i<m_MeshRenderer.sharedMaterials.Length;++i)
			m_MeshRenderer.sharedMaterials[i].SetMatrixArray("g_Bones", m_BoneMatrixs);
	}
}
