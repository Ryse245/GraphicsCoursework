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
	
	drawPhongVolume_fs4x.glsl
	Draw Phong lighting components to render targets (diffuse & specular).
*/

#version 410

#define MAX_LIGHTS 1024

// ****TO-DO: 
//	0) copy deferred Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare lighting data as uniform block
//	3) calculate lighting components (diffuse and specular) for the current 
//		light only, output results (they will be blended with previous lights)
//			-> use reverse perspective divide for position using scene depth
//			-> use expanded normal once sampled from normal g-buffer
//			-> do not use texture coordinate g-buffer

in vec4 vBiasedClipCoord;
flat in int vInstanceID;

// simple point light
struct sPointLight
{
	vec4 worldPos;					// position in world space
	vec4 viewPos;					// position in viewer space
	vec4 color;						// RGB color with padding
	float radius;					// radius (distance of effect from center)
	float radiusInvSq;				// radius inverse squared (attenuation factor)
	float pad[2];					// padding
};

uniform ubPointLight {
	sPointLight uLight[MAX_LIGHTS];
};

in vec4 vTexcoord;

uniform sampler2D uImage00;
uniform sampler2D uImage01;	//View position
uniform sampler2D uImage02;	//View normal

uniform mat4 uPB_inv;

/*uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
*/

layout(location = 6) out vec4 rtDiffuseLight;
layout(location = 7) out vec4 rtSpecularLight;


float shininess = 8.0;

float lambertize(vec4 V, vec4 L, vec4 F)
{
	//vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L - F);
	float lambProduct = max(0.0, dot(V, lightNormal));
	return lambProduct;
}

float specularHighlight(vec4 V, vec4 L, vec4 F)
{
	//vec4 fragNormal = normalize(V);
	vec4 lightNormal = normalize(L - F);
	vec4 reflectVec = reflect(-lightNormal, V);
	vec4 viewVec = normalize(-F);
	float specProduct = max(0.0, dot(reflectVec, viewVec));
	specProduct = pow(specProduct, shininess);
	return specProduct;
}


void main()
{
	vec4 viewPosition = texture(uImage01, vBiasedClipCoord.xy);
	vec4 depth = texture(uImage00, vBiasedClipCoord.xy);
	vec4 viewNorm = texture(uImage02, vBiasedClipCoord.xy);

	viewPosition = (uPB_inv * vBiasedClipCoord)/vBiasedClipCoord.w;//use depth somehow idk bro
	//viewPos /= viewPos.w;
	viewNorm = (viewNorm * 2.0) - 1.0;
	//viewNorm.w = 1.0;

	vec4 finalLightCol;
	vec4 diffuseCol;
	vec4 specularCol;

	//for (int i = 0; i < uLightCt; i++)
	//{
		//Diffuse
		diffuseCol += lambertize(viewNorm, uLight[vInstanceID].worldPos , viewPosition) * uLight[vInstanceID].color;//uLightPos[vInstanceID], uLightCol[vInstanceID
		//Specular
		specularCol += specularHighlight(viewNorm,uLight[vInstanceID].worldPos , viewPosition) * uLight[vInstanceID].color;
	//}

	diffuseCol.w = 1.0;
	rtDiffuseLight = diffuseCol;

	specularCol.w = 1.0;
	rtSpecularLight = specularCol;
	/*
	diffuseCol = diffuseCol * texture(uImage04, atlas.xy);
	diffuseCol.w = 1.0;

	specularCol = specularCol * texture(uImage05, atlas.xy);
	specularCol.w = 1.0;
	*/
	//add diffuse and specular for phong shading
	//finalLightCol = diffuseCol + specularCol;
	//finalLightCol.w = 1.0;

}
