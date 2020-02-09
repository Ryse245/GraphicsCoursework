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
	
	drawPhong_multi_shadow_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output and 
		shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy existing Phong shader	DONE
//	1) receive shadow coordinate	DONE
//	2) perform perspective divide
//	3) declare shadow map texture DONE
//	4) perform shadow test

layout(location = 0) out vec4 rtFragColor;	//Color target 0 FINAL SCENE COLOR

layout(location = 1) out vec4 rtViewPos;	//Color target 1
layout(location = 2) out vec4 rtViewNormal;	//Color target 2
layout(location = 3) out vec4 rtTexcoord; //Color target 3

layout(location = 4) out vec4 rtShadowCoord; //Color target 4

layout(location = 5) out vec4 rtShadowTest;	//Color target 5

layout(location = 6) out vec4 rtDiffTotal;	//Color target 6
layout(location = 7) out vec4 rtSpecTotal;	//Color target 7


//out vec4 rtFragColor;

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uTex_shadow;

uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

in vec2 vTextureCoord;
in vec4 vecNormal;
in vec4 viewPos;
in vec4 vShadowCoord;

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

void main()
{
	vec4 finalLightCol;
	vec4 diffuseCol;
	vec4 specularCol;

	vec4 shadowScreen;

	shadowScreen = vShadowCoord / vShadowCoord.w;
	float shadowTest = texture(uTex_shadow, shadowScreen.xy).r;
	bool inShadow = (shadowScreen.z > (shadowTest + 0.0025));
	
	
	for(int i = 0; i < uLightCt; i++)
	{
		//Diffuse
		diffuseCol +=  lambertize(vecNormal, uLightPos[i], viewPos) * uLightCol[i];
		//Specular
		specularCol +=  specularHighlight(vecNormal, uLightPos[i], viewPos) * uLightCol[i];
	}

	rtDiffTotal = diffuseCol;
	rtSpecTotal = vec4(vec3(specularCol),1.0);

	diffuseCol = diffuseCol * texture(uTex_dm, vTextureCoord);
	
	specularCol = specularCol * texture(uTex_sm, vTextureCoord);
	//add diffuse and specular for phong shading
	finalLightCol = diffuseCol + specularCol;


	rtFragColor = finalLightCol;
	rtViewPos = viewPos;
	rtViewNormal = vec4(vec3(vecNormal),1.0);
	rtTexcoord = vec4(vTextureCoord, 0.0, 1.0);
	rtShadowCoord = vShadowCoord;
	rtShadowTest = texture(uTex_shadow, shadowScreen.xy);
	if(inShadow)
	{
		rtFragColor.rgb *= 0.2;
		rtShadowTest.rgb *= 0.2;
	}
}
