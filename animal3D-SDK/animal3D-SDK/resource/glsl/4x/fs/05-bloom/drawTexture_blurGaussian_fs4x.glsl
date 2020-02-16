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
	
	drawTexture_blurGaussian_fs4x.glsl
	Draw texture with Gaussian blurring.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare uniforms for pixel size and sampling axis
//	2) implement Gaussian blur function using a 1D kernel (hint: Pascal's triangle)
//	3) sample texture using Gaussian blur function and output result

uniform sampler2D uImage00;
uniform vec2 uAxis;
uniform vec2 uSize;
layout (location = 0) out vec4 rtFragColor;

in vec2 vTextureCoord;

//center = center pixel, dir = next/prev pixel
vec4 blurGaussian0(in sampler2D img, in vec2 center, in vec2 dir) //pascal 0th row
{
	return texture(img, center);
}

vec4 blurGaussian2(in sampler2D img, in vec2 center, in vec2 dir) //pascal 2nd row
{
	vec4 c = vec4(0.0);
	c+= texture(img, center-uSize*dir);	//1 on sides of pascal triangle
	c+= texture(img, center) * 2.0;	//2 is middle of 2nd row of pascal's triangle
	c+= texture(img, center+uSize*dir);	//1 on sides of pascal triangle

	//for more distant nums in pascal triangle, multiply dir? (ex. center +/- (dir*2.0))?
	
	//return(c/4.0);
	return (c*0.25);	//c * 0.25 = c/4, 4 is added values from pascal triangle row (2+1+1)
}

vec4 blurGaussian4(in sampler2D img, in vec2 center, in vec2 dir)
{
	vec4 color = vec4(0.0);
	color+= texture(img, center-uSize*dir*2.0);	//1 on sides of pascal triangle

	color+= texture(img, center-uSize*dir)*4.0;	//4 on sides of pascal triangle

	color+= texture(img, center)*6.0;	//6 on middle of pascal triangle

	color+= texture(img, center+uSize*dir)*4.0;	//4 on sides of pascal triangle

	color+= texture(img, center+uSize*dir*2.0);	//1 on sides of pascal triangle
	return color*0.0625;
}

vec4 blurGaussian6(in sampler2D img, in vec2 center, in vec2 dir)
{
	vec4 color = vec4(0.0);
	color+= texture(img, center-(uSize*3.0)*dir);	//1 on sides of pascal triangle

	color+= texture(img, center-(uSize*2.0)*dir)*6.0;	//1 on sides of pascal triangle

	color+= texture(img, center-uSize*dir)*15.0;	//4 on sides of pascal triangle

	color+= texture(img, center)*20.0;	//6 on middle of pascal triangle

	color+= texture(img, center+uSize*dir)*15.0;	//4 on sides of pascal triangle

	color+= texture(img, center+(uSize*2.0)*dir)*6.0;	//1 on sides of pascal triangle

	color+= texture(img, center+(uSize*3.0)*dir);	//1 on sides of pascal triangle
	return color*0.015625;
}

void main()
{
	rtFragColor = blurGaussian6(uImage00,vTextureCoord,uAxis);
}

//TIP FOR BONUS: implement multiple blur/bright passes
//TIP FOR BONUS: use 1st, 3rd, etc. rows instead of even rows for 3rd bonus (no idea how)