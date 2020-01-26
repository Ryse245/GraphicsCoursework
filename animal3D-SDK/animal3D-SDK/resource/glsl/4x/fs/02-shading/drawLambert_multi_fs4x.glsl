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
	
	drawLambert_multi_fs4x.glsl
	Draw Lambert shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
uniform sampler2D uTex_dm;
//	2) declare uniform variables for lights; see demo code for hints
//CORRECT
uniform int uLightCt;
uniform vec4 uLightCol;
//INCORRECT
uniform float uLightSz;
uniform float uLightSzInvSq;
uniform vec3 uLightPos;

//	3) declare inbound varying data
in vec2 vTextureCoord;
in vec3 vecNormal;
in vec4 viewPos;
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

out vec4 rtFragColor;

float lambertize()
{
	vec3 fragNormal = normalize(vecNormal);
	vec3 lightNormal = normalize(uLightPos);
	float lambProduct = max(0.0, dot(fragNormal, lightNormal));
	return lambProduct;
}

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE RED
	//rtFragColor = vec4(vTextureCoord, 0,0);
	//rtFragColor = vec4(vecNormal,0);
	//rtFragColor = uLightCol;
	//rtFragColor = vec4(abs(uLightCt), 0,0,0);

	//rtFragColor = lambertize() * uLightCol * texture(uTex_dm, vTextureCoord);
	rtFragColor = texture(uTex_dm, vTextureCoord);
}
