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
	
	passLightingData_shadowCoord_transform_vs4x.glsl
	Vertex shader that prepares and passes lighting data. Outputs transformed 
		position attribute and all others required for lighting. Also computes 
		and passes shadow coordinate.
*/

#version 410

// ****TO-DO: 
//	0) copy previous lighting data vertex shader	DONE
//	1) declare MVPB matrix for light	DONE
//	2) declare varying for shadow coordinate	DONE
//	3) calculate and pass shadow coordinate	DONE
uniform mat4 uMV;
uniform mat4 uMVPB_other;

out vec4 vShadowCoord;

out vec4 viewPos;

uniform mat4 uP;

layout (location = 2) in vec4 normal;

uniform mat4 uMV_nrm;

out vec4 vecNormal;

layout (location = 8) in vec4 aTexCoord; 
uniform mat4 uAtlas;
out vec2 vTextureCoord;
out float vDotProd;


layout (location = 0) in vec4 aPosition;

void main()
{
	viewPos = uMV * aPosition;

	gl_Position =  uP * viewPos;

	vecNormal = vec4(uMV_nrm * normal);
		
	vTextureCoord = vec2 (uAtlas * aTexCoord);

	vShadowCoord = uMVPB_other * aPosition;

	//vDotProd = dot(normalize(up vector - aPosition), normalize(aPosition-viewPos));
	//Calculate dot product of vertex and camera normal, send to FS?
}
