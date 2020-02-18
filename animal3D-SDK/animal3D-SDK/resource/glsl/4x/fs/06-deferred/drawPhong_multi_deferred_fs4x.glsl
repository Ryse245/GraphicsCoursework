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
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as uniform block FALSE, USE ORIGINAL PHONG SHADER (COPY PHONG SHADER, REPLACE VARYING INPUTS WITH TEXTURE SAMPLES) (READ IDLE-RENDER TO FIND TEXTURES)
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled

in vec4 vTexcoord;

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE CYAN (and others)
	rtFragColor = vec4(0.0, 1.0, 1.0, 1.0);
	rtDiffuseMapSample = vec4(0.0, 0.0, 1.0, 1.0);
	rtSpecularMapSample = vec4(0.0, 1.0, 0.0, 1.0);
	rtDiffuseLightTotal = vec4(1.0, 0.0, 1.0, 1.0);
	rtSpecularLightTotal = vec4(1.0, 1.0, 0.0, 1.0);
}
