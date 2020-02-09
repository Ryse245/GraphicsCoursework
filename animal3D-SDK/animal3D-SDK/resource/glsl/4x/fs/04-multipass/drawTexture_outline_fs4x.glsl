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
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader	DONE?
//	1) implement outline algorithm - see render code for uniform hints

uniform sampler2D uTex_dm;
uniform vec4 uColor;
uniform vec2 uAxis;
uniform vec2 uSize;
in vec2 vTextureCoord;

layout(location = 0) out vec4 rtFragColor;

layout(location = 3) out vec4 rtTexcoord;


void main()
{
	vec4 sampleTex_dm = texture(uTex_dm, vTextureCoord);
	//rtFragColor = sampleTex_dm;
	rtFragColor = texture(uTex_dm, vTextureCoord);

	rtTexcoord = vec4(vTextureCoord, 0.0, 1.0);

}