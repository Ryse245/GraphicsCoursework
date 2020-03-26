/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	passTangentBasis_transform_instanced_vs4x.glsl
	Transforms all attributes by their respective matrix, sends full 
		tangent basis and other lighting data.
*/

#version 430

#define MAX_INSTANCES	16
#define MAX_MODELS		 8

// ****TO-DO: 
//	0) nothing

layout (location = 8)	in vec4 aTexcoord;
layout (location = 10)	in vec4 aTangent;
layout (location = 11)	in vec4 aBitangent;
layout (location = 2)	in vec4 aNormal;
layout (location = 0)	in vec4 aPosition;


struct sMatrixStack
{
	mat4 modelMat, modelMatInverse, modelNormalMat;
	mat4 modelViewMat, modelViewMatInverse, modelViewNormalMat;
	mat4 modelViewProjectionMat;
	mat4 atlasMat;
};

uniform ubTransformStack {
	sMatrixStack uTransform[MAX_INSTANCES][MAX_MODELS];
};
uniform int uIndex;


out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
};

out vec4 testPos;

void main()
{
	vVertexID = gl_VertexID;
	int i = vInstanceID = gl_InstanceID;
	int m = vModelID = uIndex;

	mat4 tangentBasis_object = mat4(aTangent, aBitangent, aNormal, aPosition);

	sMatrixStack t = uTransform[i][m];
	vTexcoord_atlas = t.atlasMat * aTexcoord;
	vTangentBasis_view = t.modelViewNormalMat * tangentBasis_object;
	vTangentBasis_view[3] = t.modelViewMat * aPosition;
	gl_Position = t.modelViewProjectionMat * aPosition;
	testPos = gl_Position;
}
