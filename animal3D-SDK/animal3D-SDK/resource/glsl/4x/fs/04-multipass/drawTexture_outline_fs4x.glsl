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

//https://computergraphics.stackexchange.com/questions/3646/opengl-glsl-sobel-edge-detection-filter and https://en.wikipedia.org/wiki/Sobel_operator were used to figure out and implement the sobel algorithm
// ****TO-DO: 
//	0) copy existing texturing shader	DONE
//	1) implement outline algorithm - see render code for uniform hints

uniform sampler2D uTex_dm;
uniform vec4 uColor;
in vec2 vTextureCoord;
//in float vDotProd;

layout(location = 0) out vec4 rtFragColor;

layout(location = 3) out vec4 rtTexcoord;

mat3 sobelX = mat3(
	1.0, 2.0, 1.0,
	0.0, 0.0, 0.0,
	-1.0,-2.0, -1.0);

mat3 sobelY = mat3(
	1.0, 0.0, -1.0,
	2.0, 0.0, -2.0,
	1.0, 0.0, -1.0);

void main()
{
	vec4 sampleTex_dm = texture(uTex_dm, vTextureCoord);

	mat3 lengthMat;
	float xProd;
	float yProd;

	for(int i = 0; i < 3; i++)
	{
		for(int j = 0; j < 3; j++)
		{
			vec3 samples = texelFetch(uTex_dm, ivec2(gl_FragCoord) + ivec2(i-1,j-1), 0).rgb;
			lengthMat[i][j] = length(samples);
		}
	}
	
	for(int k = 0; k < 3; k++)
	{
		xProd += dot(sobelX[k], lengthMat[k]);	//Combine dot products of x and y from sobel matrices and length matrix
		yProd += dot(sobelY[k], lengthMat[k]);
	}

	float allProd = sqrt((xProd * xProd) + (yProd * yProd));


	//vec4 bigger = texture(uTex_dm, normalize(vTextureCoord) * uSize);
	//rtFragColor = bigger;

	//rtFragColor = bigger + sampleTex_dm - (bigger*sampleTex_dm);
	
	if(allProd > 0.75)
	{
		rtFragColor.rgb = uColor.rgb;
	}

	else
	{
		rtFragColor = sampleTex_dm;
	}
	//rtFragColor = vec4(sampleTex_dm.rgb - vec3(allProd) ,1.0);	
	
	//rtFragColor = vec4(uSize,0,0);
	//2 options
	//1. Create slightly larger object, display on top
	//2. If normal of position is perpendicular to camera
	

	rtTexcoord = vec4(vTextureCoord, 0.0, 1.0);

}