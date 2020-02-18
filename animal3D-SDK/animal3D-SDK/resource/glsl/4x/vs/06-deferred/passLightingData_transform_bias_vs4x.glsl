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
	
	passLightingData_transform_vs4x.glsl
	Vertex shader that prepares and passes lighting data. Outputs transformed 
		position attribute and all others required for lighting.
*/

#version 410

// ****TO-DO: 
//	0) nothing

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec4 aNormal;
layout (location = 8) in vec4 aTexcoord;

uniform mat4 uMV, uP, uPB, uMV_nrm, uAtlas;

//For reading in, copy and switch "out" to "in"
out vbLightingData {
	vec4 vViewPosition;
	vec4 vViewNormal;
	vec4 vTexcoord;
	vec4 vBiasedClipCoord;
};

void main()
{
	vViewPosition = uMV * aPosition;
	vViewNormal = uMV_nrm * aNormal;
	vTexcoord = uAtlas * aTexcoord;
	vBiasedClipCoord = uPB * vViewPosition;
	gl_Position = uP * vViewPosition;
}
