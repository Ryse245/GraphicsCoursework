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
	
	drawLambert_multi_mrt_fs4x.glsl
	Draw Lambert shading model for multiple lights with MRT output.
*/

#version 410

////https://learnopengl.com/Lighting/Basic-Lighting helped with finding out what to do

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
uniform sampler2D uTex_dm;
//	2) declare uniform variables for lights; see demo code for hints

uniform int uLightCt;

uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

//	3) declare inbound varying data
in vec2 vTexcoord;
in vec4 vecNormal;
in vec4 viewPos;
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

//	5) set location of final color render target (location 0)
layout(location = 0) out vec4 rtFragColor;

//	6) declare render targets for each attribute and shading component
out vec4 vTexcoord;
out vec4 rtVecNormal;
out vec4 rtViewPos;

float lambertize(vec4 V, vec4 L, vec4 F)
{
	vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L-F);
	float lambProduct = max(0.0, dot(fragNormal, lightNormal));
	return lambProduct;
}


void main()
{
	vec4 finalLightCol;

	for(int i = 0; i < uLightCt; i++)
	{
		finalLightCol +=  lambertize(vecNormal, uLightPos[i], viewPos) * uLightCol[i];
	}

	rtFragColor = finalLightCol * texture(uTex_dm, vTextureCoord);

}


