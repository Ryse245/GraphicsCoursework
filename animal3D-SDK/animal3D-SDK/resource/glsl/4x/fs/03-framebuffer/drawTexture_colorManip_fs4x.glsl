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
	
	drawTexture_colorManip_fs4x.glsl
	Draw texture sample and manipulate result.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
uniform sampler2D uTex_dm;
uniform double uTime;
//	2) declare inbound varying for texture coordinate
in vec2 vTextureCoord;
//	4) modify sample in some creative way
//	5) assign modified sample to output color

out vec4 rtFragColor;

void main()
{
//	3) sample texture using texture coordinate
	//vec4 semiFinal = (texture(uTex_dm, vTextureCoord)*((sin(float(2*uTime))+1)/2));
	vec3 colorEdit;
	vec4 semiFinal = texture(uTex_dm, vTextureCoord);
	colorEdit = semiFinal.rgb;
	vec2 midPoint = vec2(0.5,0.5);
	//colorEdit = (semiFinal.rgb*(sin(float(2*uTime))+1)/2);

	//if(length(abs(vTextureCoord - midPoint)) < 0.25)
	//{
	colorEdit.x += sin(vTextureCoord.x * 30 + float(2*uTime));
	colorEdit.y += cos(vTextureCoord.y * 30 + float(2*uTime));
	//}


	// DUMMY OUTPUT: all fragments are OPAQUE LIGHT GREY
	rtFragColor = vec4(colorEdit, semiFinal.w);
}
//sin(float(uTime))