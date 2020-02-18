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
	
	drawPhongVolume_fs4x.glsl
	Draw Phong lighting components to render targets (diffuse & specular).
*/

#version 410

#define MAX_LIGHTS 1024

// ****TO-DO: 
//	0) copy deferred Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare lighting data as uniform block
//	3) calculate lighting components (diffuse and specular) for the current 
//		light only, output results (they will be blended with previous lights)
//			-> use reverse perspective divide for position using scene depth
//			-> use expanded normal once sampled from normal g-buffer
//			-> do not use texture coordinate g-buffer

in vec4 vBiasedClipCoord;
flat in int vInstanceID;

// simple point light
struct sPointLight
{
	vec4 worldPos;					// position in world space
	vec4 viewPos;					// position in viewer space
	vec4 color;						// RGB color with padding
	float radius;					// radius (distance of effect from center)
	float radiusInvSq;				// radius inverse squared (attenuation factor)
	float pad[2];					// padding
};

uniform ubPointLight {
	sPointLight uLight[MAX_LIGHTS];
};

layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	rtDiffuseLight = vec4(1.0, 0.0, 1.0, 1.0);
	rtSpecularLight = vec4(1.0, 0.0, 1.0, 1.0);
}
