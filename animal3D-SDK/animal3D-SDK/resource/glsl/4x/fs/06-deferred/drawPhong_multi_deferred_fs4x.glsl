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

uniform sampler2D uImage00;
uniform sampler2D uImage01;	//View position
uniform sampler2D uImage02;	//View normal
uniform sampler2D uImage03;	//Atlas texcoord

uniform sampler2D uImage04;
uniform sampler2D uImage05;
uniform mat4 uPB_inv;

uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtViewPosition;
layout (location = 2) out vec4 rtViewNormal;
layout (location = 3) out vec4 rtAtlasTexcoord;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;


float shininess = 8.0;

float lambertize(vec4 V, vec4 L, vec4 F)
{
	//vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L-F);
	float lambProduct = max(0.0, dot(V, lightNormal));
	return lambProduct;
}

float specularHighlight(vec4 V, vec4 L, vec4 F)
{
	//vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L-F);
	vec4 reflectVec = reflect(-lightNormal, V);
	vec4 viewVec = normalize(-F);
	float specProduct = max(0.0,dot(reflectVec,viewVec));
	specProduct = pow(specProduct,shininess);
	return specProduct;
}


void main()
{
	vec4 viewPos = texture(uImage01, vTexcoord.xy);
	vec4 depth = texture(uImage00, vTexcoord.xy);
	vec4 viewNorm = texture(uImage02, vTexcoord.xy);
	vec4 atlas = texture(uImage03, vTexcoord.xy);

	viewPos = uPB_inv*viewPos;//use depth somehow idk bro
	viewPos /= viewPos.w;
	viewNorm = (viewNorm*2.0) - 1.0;
	//viewNorm.w = 1.0;

	vec4 finalLightCol;
	vec4 diffuseCol;
	vec4 specularCol;

	for(int i = 0; i < uLightCt; i++)
	{
		//Diffuse
		diffuseCol +=  lambertize(viewNorm, uLightPos[i], viewPos) * uLightCol[i];
		//Specular
		specularCol +=  specularHighlight(viewNorm, uLightPos[i], viewPos) * uLightCol[i];
	}

	diffuseCol.w = 1.0;
	rtDiffuseLightTotal = diffuseCol;

	specularCol.w = 1.0;
	rtSpecularLightTotal = specularCol;

	diffuseCol = diffuseCol * texture(uImage04, atlas.xy);
	diffuseCol.w = 1.0;
	
	specularCol = specularCol * texture(uImage05, atlas.xy);
	specularCol.w = 1.0;

	//add diffuse and specular for phong shading
	finalLightCol = diffuseCol + specularCol;
	finalLightCol.w = 1.0;

	rtFragColor = finalLightCol * texture(uImage00, atlas.xy);
	rtDiffuseMapSample = texture(uImage04, atlas.xy);
	rtDiffuseMapSample.w = 1.0;
	rtSpecularMapSample = texture(uImage05, atlas.xy);
	rtSpecularMapSample.w = 1.0;

	
	rtViewPosition = viewPos;
	rtViewNormal = vec4(viewNorm.rgb,1.0);
	rtAtlasTexcoord = atlas;
}
