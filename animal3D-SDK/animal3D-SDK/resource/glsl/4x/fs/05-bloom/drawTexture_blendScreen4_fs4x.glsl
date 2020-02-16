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
	
	drawTexture_blendScreen4_fs4x.glsl
	Draw blended sample from multiple textures using screen function.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare additional texture uniforms
//	2) implement screen function with 4 inputs
//	3) use screen function to sample input textures



uniform sampler2D uImage00;	//1/8 pass
uniform sampler2D uImage01;	//1/4 pass
uniform sampler2D uImage02;	//1/2 pass
uniform sampler2D uImage03;	//"Normal" pass

in vec2 vTextureCoord;

layout (location = 0) out vec4 rtFragColor;

vec3 screenFunc(in sampler2D img01, in sampler2D img02,in sampler2D img03,in sampler2D img04)
{
	vec3 image01tex = texture(img01, vTextureCoord).rgb;
	vec3 image02tex = texture(img02, vTextureCoord).rgb;
	vec3 image03tex = texture(img03, vTextureCoord).rgb;
	vec3 image04tex = texture(img04, vTextureCoord).rgb;

	vec3 finalScreen = vec3(1.0) - (vec3(1.0)-image01tex)*(vec3(1.0)-image02tex)*(vec3(1.0)-image03tex)*(vec3(1.0)-image04tex);

	return finalScreen;
}

void main()
{
	vec3 screen = screenFunc(uImage00, uImage01, uImage02, uImage03);
	// DUMMY OUTPUT: all fragments are OPAQUE YELLOW
	rtFragColor = vec4(screen, 1.0);
}
