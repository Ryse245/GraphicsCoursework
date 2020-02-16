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

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
uniform sampler2D uTex_dm;
//	2) declare uniform variables for lights; see demo code for hints

uniform int uLightCt;

uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

//	3) declare inbound varying data
in vec2 vTextureCoord;
in vec4 vecNormal;
in vec4 viewPos;

//	5) set location of final color render target (location 0)
layout(location = 0) out vec4 rtFragColor;	//Color target 0 FINAL SCENE COLOR

//	6) declare render targets for each attribute and shading component

layout(location = 1) out vec4 rtViewPos;	//Color target 1
layout(location = 2) out vec4 rtViewNormal;	//Color target 2
layout(location = 3) out vec4 rtTexcoord; //Color target 3
layout(location = 4) out vec4 rtDiffMap; //Color target 4
//No color target 5, Lambert doesn't use specular
layout(location = 6) out vec4 rtDiffTotal;	//Color target 6
//No color target 7, Lambert doesn't use specular
//Depth buffer?


//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!
//float lambertize(vec4 V, vec4 L, vec4 F)
float lambertize(vec4 fragNormal, vec4 lightNormal)
{
	//vec4 fragNormal = normalize(V);
	//vec4 lightNormal = normalize(L-F);
	float lambProduct = max(0.0, dot(fragNormal, lightNormal));
	return lambProduct;
}


void main()
{
	vec4 finalLightCol;

	vec4 fragNorm = normalize(vecNormal);
	vec4 lightNorms[4];
	for(int i = 0; i < uLightCt; i++)
	{
		lightNorms[i] = normalize(uLightPos[i] - viewPos);
	}


	for(int i = 0; i < uLightCt; i++)
	{
		finalLightCol +=  lambertize(fragNorm, lightNorms[i]) * uLightCol[i];
		//finalLightCol +=  lambertize(vecNormal, uLightPos[i], viewPos) * uLightCol[i];
	}

	rtFragColor = finalLightCol * texture(uTex_dm, vTextureCoord);
	rtViewPos = viewPos;
	rtViewNormal = vec4(vec3(vecNormal),1.0);
	rtTexcoord = vec4(vTextureCoord, 0.0, 1.0);
	rtDiffMap = texture(uTex_dm, vTextureCoord);

	rtDiffTotal = finalLightCol;

}
