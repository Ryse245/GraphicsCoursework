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
	
	drawFractalPattern_fs.glsl
	draws fractal pattern as a texture to the objects
*/

#version 430

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) nothing

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
};

//Mine
in vec4 testPos;

uniform vec4 uColor;
uniform double uTime;
uniform sampler2D uTex_dm, uTex_sm;
uniform sampler2D tex_ramp_dm;


layout (location = 0) out vec4 rtMandelbrot;;
layout (location = 1) out vec4 rtJulia;
layout (location = 2) out vec4 rtNoise;

float random(in vec2 uv)
{
	return fract(sin(dot(uv.xy, vec2(0.5,0.5)))*1.0);
}

float randomNoise(in vec2 uv)
{
	vec2 floorVec = floor(uv);
	vec2 fractVec = fract(uv);

	float a,b,c,d;
	a = random(floorVec);
	b = random(floorVec + vec2(1.0, 0.0));
	c = random(floorVec + vec2(0.0, 1.0));
	d = random(floorVec + vec2(1.0, 1.0));

	vec2 fractCombo = fractVec * fractVec * (3.0 - (2.0*fractVec));
	return mix(a,b,fractCombo.x) + (c-a)* fractCombo.y * (1.0 - fractCombo.x) + (d-b) * fractCombo.x * fractCombo.y;
}

float fbm(in vec2 uv)
{
	/*float initValue = 0.0;
	float amplitude = 0.5;
	float frequency = 0.0;
	for(int i = 0; i < 6; i++)
	{
		initValue += amplitude * randomNoise(uv);
		uv *= 2.0;
		amplitude *= 0.5;
	}
	return initValue;
	*/
	float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < 5; ++i) {
        v += a * randomNoise(uv);
        uv = rot * uv * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec4 finalWarp()
{
	//vec2 uv = gl_FragCoord.xy/vec2(960,540); //resolution is 960x540(main_win.c line 61), needed to get the uv
	vec2 uv = vTexcoord_atlas.xy;
	vec3 color = vec3(0.0);
	vec2 r, q = vec2(0.0);
	
	q.x = fbm(uv+ float(uTime));
	q.y = fbm(uv +vec2(1.0));
	
	r.x = fbm(uv + 1.0*q + vec2(1.7,9.2)+0.15 * float(uTime));
	r.y = fbm(uv + 1.0*q + vec2(8.3,2.8)+0.126 * float(uTime));

	float f = fbm(uv + r);

	color = mix(vec3(0.101961,0.619608,0.666667),
                vec3(0.666667,0.666667,0.498039),
                clamp((f*f)*4.0,0.0,1.0));

    color = mix(color,
                vec3(0,0,0.164706),
                clamp(length(q),0.0,1.0));

    color = mix(color,
                vec3(0.666667,1,1),
                clamp(length(r.x),0.0,1.0));

	return vec4(color,1.0);
	//Continued: https://thebookofshaders.com/13/
}


//Currently used fractal pattern
vec4 fractalTest()
{
	//http://nuclear.mutantstargoat.com/articles/sdr_fract/ fractals
	vec2 z, c;
	/*Manelbrot
    c.x = (vTexcoord_atlas.x - vTexcoord_atlas.x*0.5) * 2.0 - testPos.x*0.2;	//Testpos deals with the scale of the fractal pattern, the subtraction from vTexcoord_atlas deals with position on screen (I think)
    c.y = (vTexcoord_atlas.y - vTexcoord_atlas.y*0.5) * 2.0 - testPos.y*0.2;
	*/

	///*Julia
	c.x = 4.0 * (vTexcoord_atlas.x -0.5);
	c.y = 3.0 * (vTexcoord_atlas.y - 0.5);
	//*/
	int i;
    z = c;
    for(i=0; i<10; i++) {	//i variable deals with how detailed the fractal pattern becomes
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 173.0) break;
        z.x = x;
        z.y = y;
    }
	return texture(tex_ramp_dm,vec2(i == 10.0 ? 0.0 : float(i))/100.0);
}

vec4 mandelbrotFractal()
{
	vec2 z, c;
	//Manelbrot
    c.x = (vTexcoord_atlas.x - vTexcoord_atlas.x*0.5) * 2.0 - testPos.x*0.2;	//Testpos deals with the scale of the fractal pattern, the subtraction from vTexcoord_atlas deals with position on screen (I think)
    c.y = (vTexcoord_atlas.y - vTexcoord_atlas.y*0.5) * 2.0 - testPos.y*0.2;
	
	int i;
    z = c;
    for(i=0; i<10; i++) {	//i variable deals with how detailed the fractal pattern becomes
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 173.0) break;
        z.x = x;
        z.y = y;
    }
	return texture(tex_ramp_dm,vec2(i == 10.0 ? 0.0 : float(i))/100.0);
}

vec4 juliaFractal()
{
	vec2 z, c;
	//Julia
	c.x = 4.0 * (vTexcoord_atlas.x -0.5);
	c.y = 3.0 * (vTexcoord_atlas.y - 0.5);

	int i;
    z = c;
    for(i=0; i<10; i++) {	//i variable deals with how detailed the fractal pattern becomes
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 173.0) break;
        z.x = x;
        z.y = y;
    }
	return texture(tex_ramp_dm,vec2(i == 10.0 ? 0.0 : float(i))/100.0);
}
void main()
{
	// textures
	vec4 sample_dm = texture(uTex_dm, vTexcoord_atlas.xy);
	vec4 sample_sm = texture(uTex_sm, vTexcoord_atlas.xy);

	//rtMandelbrot.rgb = mandelbrotFractal().rgb;	//Display the fractal pattern created
	rtMandelbrot.rgb = vec3(1.0);	//Display the fractal pattern created
	//rtMandelbrot.a = sample_dm.a;
	
	//rtJulia.rgb = juliaFractal().rgb;	//Display the fractal pattern created
	rtJulia.rgb = vec3(1.0,0.0,0.0);	//Display the fractal pattern created
	//rtJulia.a = sample_dm.a;

	// output attributes
	//rtNoise = finalWarp();
	rtNoise = vec4(1.0);

	//**Target 0 will be mandelbrot, 1 Julia, 2 fractal noise***
}
