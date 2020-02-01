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
	
	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410
//https://learnopengl.com/Lighting/Basic-Lighting helped with finding out what to do

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
//	2) declare uniform variables for lights; see demo code for hints
uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

//	3) declare inbound varying data
in vec2 vTextureCoord;
in vec4 vecNormal;
in vec4 viewPos;

//	4) implement Phong shading model

//no uniform shininess given so went with 25 which looked pretty similar to demo
float shininess = 25.0;

float lambertize(vec4 V, vec4 L, vec4 F)
{
	vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L-F);
	float lambProduct = max(0.0, dot(fragNormal, lightNormal));
	return lambProduct;
}

float specularHighlight(vec4 V, vec4 L, vec4 F)
{
	vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L-F);
	vec4 reflectVec = reflect(-lightNormal, fragNormal);
	vec4 viewVec = normalize(-F);
	float specProduct = max(0.0,dot(reflectVec,viewVec));
	specProduct = pow(specProduct,shininess);
	return specProduct;
}
//	Note: test all data and inbound values before using them!

out vec4 rtFragColor;
 
void main()
{
	vec4 finalLightCol;
	vec4 diffuseCol;
	vec4 specularCol;

	for(int i = 0; i < uLightCt; i++)
	{
		//Diffuse
		diffuseCol +=  lambertize(vecNormal, uLightPos[i], viewPos) * uLightCol[i];
		//Specular
		specularCol +=  specularHighlight(vecNormal, uLightPos[i], viewPos) * uLightCol[i];
	}

	diffuseCol = diffuseCol * texture(uTex_dm, vTextureCoord);
	
	specularCol = specularCol * texture(uTex_sm, vTextureCoord);

	//add diffuse and specular for phong shading
	finalLightCol = diffuseCol + specularCol;

	rtFragColor = finalLightCol;
	//rtFragColor = vec4(0.0, 1.0, 0.0, 1.0);
}
