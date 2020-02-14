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
	
	drawTexture_brightPass_fs4x.glsl
	Draw texture sample with brightening.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement brightness function (e.g. luminance)
//	2) use brightness to implement tone mapping or just filter out dark areas

uniform sampler2D uImage00;

layout (location = 0) out vec4 rtFragColor;
out vec4 rtLuminence;

in vec2 vTextureCoord;
//1
float relLuminance(vec3 c)
{
	return(0.2126*c.r + 0.7152*c.g + 0.0722*c.b);
}

void main()
{
	vec4 color = texture(uImage00,vTextureCoord);
	float luminance = relLuminance(color.rgb);
	//bright pass function to make tone map, multiply tone map by input image
	rtFragColor = color;
}
