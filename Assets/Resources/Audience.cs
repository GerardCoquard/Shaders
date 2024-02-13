using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class Audience : MonoBehaviour
{
	MeshRenderer m_MeshRenderer;
	MeshFilter m_MeshFilter;

	void Start()
	{
		InitHotValues();
	}
	void InitHotValues()
	{
		m_MeshRenderer=GetComponent<MeshRenderer>();
		m_MeshFilter=GetComponent<MeshFilter>();
		if(m_MeshFilter.sharedMesh==null)
			BuildMesh();
	}
	void LateUpdate()
	{
#if UNITY_EDITOR
		InitHotValues();
#endif
	}
	public void BuildMesh()
	{
		Transform[] l_Transforms=gameObject.GetComponentsInChildren<Transform>();
		int l_ElementsCount=l_Transforms.Length;
		Vector3[] l_UVs=new Vector3[l_ElementsCount*4];
		Vector3[] l_Vertices=new Vector3[l_ElementsCount*4];
		int[] l_Indices=new int[l_ElementsCount*6];

		for(int i=0; i<l_Transforms.Length;++i)
		{
			Transform l_Transform=l_Transforms[i];
			/*
			 A ------ B 
			 |      / |
			 |   /    |
			 | /      |
			 C ------ D
			 * 
			*/
			Vector3 l_PosA=l_Transform.position+new Vector3(-1.0f, 1.0f, 0.0f);
			Vector3 l_PosB=l_Transform.position+new Vector3(1.0f, 1.0f, 0.0f);
			Vector3 l_PosC=l_Transform.position+new Vector3(-1.0f, 0.0f, 0.0f);
			Vector3 l_PosD=l_Transform.position+new Vector3(1.0f, 0.0f, 0.0f);
			l_Vertices[i*4]=l_PosA;
			l_Vertices[(i*4)+1]=l_PosB;
			l_Vertices[(i*4)+2]=l_PosC;
			l_Vertices[(i*4)+3]=l_PosD;

			float l_Id=Random.Range(0, 4);
			Vector3 l_UVA=new Vector3(0.0f, 1.0f, l_Id);
			Vector3 l_UVB=new Vector3(1.0f, 1.0f, l_Id);
			Vector3 l_UVC=new Vector3(0.0f, 0.0f, l_Id);
			Vector3 l_UVD=new Vector3(1.0f, 0.0f, l_Id);

			l_UVs[i*4]=l_UVA;
			l_UVs[(i*4)+1]=l_UVB;
			l_UVs[(i*4)+2]=l_UVC;
			l_UVs[(i*4)+3]=l_UVD;
			

			l_Indices[i*6]=i*4;
			l_Indices[(i*6)+1]=(i*4)+1;
			l_Indices[(i*6)+2]=(i*4)+2;

			l_Indices[(i*6)+3]=(i*4)+1;
			l_Indices[(i*6)+4]=(i*4)+3;
			l_Indices[(i*6)+5]=(i*4)+2;
		}
		Mesh l_Mesh=new Mesh();
		l_Mesh.vertices=l_Vertices;
		l_Mesh.SetUVs(0, l_UVs);
		l_Mesh.SetIndices(l_Indices, MeshTopology.Triangles, 0);
		m_MeshFilter=GetComponent<MeshFilter>();
		m_MeshFilter.sharedMesh=l_Mesh;
	}
}

#if UNITY_EDITOR

[CustomEditor(typeof(Audience))]
public class AudienceEditor : Editor
{
	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();
		Audience l_Audience=(Audience)target;
		if(GUILayout.Button("Build mesh"))
			l_Audience.BuildMesh();
	}
}
#endif