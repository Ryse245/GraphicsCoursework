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
	
	drawPhong_multi_forward_mrt_fs4x.glsl
	Draw Phong shading model using forward light set.
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

struct sPointLight
{
	vec4 worldPos;
	vec4 viewPos;
	vec4 color;
	float radius;
	float radiusInvSq;
	float radiusInv;
	float radiusSq;
};


uniform ubPointLight {
	sPointLight uPointLight[MAX_LIGHTS];
};

uniform int uLightCt;
uniform vec4 uColor;
uniform double uTime;
uniform sampler2D uTex_dm, uTex_sm;
uniform sampler2D tex_ramp_dm;


// final color
layout (location = 0) out vec4 rtFragColor;

// attribute data
layout (location = 1) out vec4 rtAtlasTexcoord;
layout (location = 2) out vec4 rtViewTangent;
layout (location = 3) out vec4 rtViewBitangent;
layout (location = 4) out vec4 rtViewNormal;
layout (location = 5) out vec4 rtViewPosition;

// lighting data
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;


float pow64(float v)
{
	v *= v;	// ^2
	v *= v;	// ^4
	v *= v;	// ^8
	v *= v;	// ^16
	v *= v;	// ^32
	v *= v;	// ^64
	return v;
}


vec3 refl(in vec3 v, in vec3 n, in float d)
{
	return ((2.0 * d) * n - v);
}


float calcDiffuseCoefficient(
	out vec3 lightVec, out float lightDist, out float lightDistSq,
	in vec3 lightPos, in vec3 fragPos, in vec3 fragNrm)
{
	lightVec = lightPos - fragPos;
	lightDistSq = dot(lightVec, lightVec);
	lightDist = sqrt(lightDistSq);
	lightVec /= lightDist;
	return dot(lightVec, fragNrm);
}


float calcSpecularCoefficient(
	out vec3 reflVec, out vec3 eyeVec,
	in vec3 lightVec, in float diffuseCoefficient,
	in vec3 fragPos, in vec3 fragNrm, in vec3 eyePos)
{
	reflVec = refl(lightVec, fragNrm, diffuseCoefficient);
	eyeVec = normalize(eyePos - fragPos);
	return dot(reflVec, eyeVec);
}


float calcAttenuation(
	float lightDist, float lightDistSq,
	float lightSz, float lightSzInvSq, float lightSzInv, float lightSzSq)
{
//	float atten = max(0.0, (1.0 - lightDistSq * lightSzInvSq));
	float atten = (1.0 / (1.0 + 2.0 * lightDist * lightSzInv + lightDistSq * lightSzInvSq));
	return atten;
}


void addPhongComponents(
	inout vec3 diffuseLightTotal, out float diffuseCoefficient,
	inout vec3 specularLightTotal, out float specularCoefficient,
	in vec3 lightPos, in vec3 lightCol,
	in float lightSz, in float lightSzInvSq, in float lightSzInv, in float lightSzSq,
	in vec3 fragPos, in vec3 fragNrm, in vec3 eyePos)
{
	float lightDist, lightDistSq, attenuation;
	vec3 lightVec, reflVec, eyeVec;
	vec3 attenuationColor;

	diffuseCoefficient = calcDiffuseCoefficient(
		lightVec, lightDist, lightDistSq,
		lightPos, fragPos, fragNrm);
	specularCoefficient = calcSpecularCoefficient(
		reflVec, eyeVec,
		lightVec, diffuseCoefficient,
		fragPos, fragNrm, eyePos);
	attenuation = calcAttenuation(
		lightDist, lightDistSq,
		lightSz, lightSzInvSq, lightSzInv, lightSzSq);

	diffuseCoefficient = max(0.0, diffuseCoefficient);
	specularCoefficient = pow64(max(0.0, specularCoefficient));

	attenuationColor = attenuation * lightCol;
	diffuseLightTotal += attenuationColor * diffuseCoefficient;
	specularLightTotal += attenuationColor * specularCoefficient;
}

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

	// DUMMY OUTPUT: all fragments are colored based on model index
//	vec4 color[6] = vec4[6] ( vec4(1.0, 0.0, 0.0, 1.0), vec4(1.0, 1.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0), vec4(0.0, 1.0, 1.0, 1.0), vec4(0.0, 0.0, 1.0, 1.0), vec4(1.0, 0.0, 1.0, 1.0) );
//	rtFragColor = color[vModelID % 6];

	mat4 tangentBasis_view = mat4(
		normalize(vTangentBasis_view[0]),
		normalize(vTangentBasis_view[1]),
		normalize(vTangentBasis_view[2]),
		vTangentBasis_view[3]
	);

	vec4 T = tangentBasis_view[0];
	vec4 B = tangentBasis_view[1];
	vec4 N = tangentBasis_view[2];
	vec4 P = tangentBasis_view[3];

	int i;
	sPointLight light;
	float kd, ks;
	vec3 eyePos = vec3(0.0);
	vec3 ambient = uColor.rgb * 0.1,
		diffuseLightTotal = vec3(0.0),
		specularLightTotal = diffuseLightTotal;

	for (i = 0; i < uLightCt; ++i)
	{
		light = uPointLight[i];
		addPhongComponents(
			diffuseLightTotal, kd,
			specularLightTotal,ks,
			light.viewPos.xyz, light.color.rgb,
			light.radius, light.radiusInvSq, light.radiusInv, light.radiusSq,
			P.xyz, N.xyz, eyePos);
	}


	// textures
	vec4 sample_dm = texture(uTex_dm, vTexcoord_atlas.xy);
	vec4 sample_sm = texture(uTex_sm, vTexcoord_atlas.xy);


	// final color
	
	rtFragColor.rgb = ambient
					+ sample_dm.rgb * diffuseLightTotal
					+ sample_sm.rgb * specularLightTotal;
	
	rtFragColor.rgb = juliaFractal().rgb;	//Display the fractal pattern created
	rtFragColor.a = sample_dm.a;
	
	// output attributes
	rtAtlasTexcoord = mandelbrotFractal();
	rtViewTangent = finalWarp();
	rtViewBitangent = vec4(B.xyz * 0.5 + 0.5, 1.0);
	rtViewNormal = vec4(N.xyz * 0.5 + 0.5, 1.0);
	rtViewPosition = P;

	// output lighting
	//rtDiffuseLightTotal = vec4(diffuseLightTotal, 1.0);
	rtDiffuseLightTotal = texture(tex_ramp_dm,vTexcoord_atlas.xy);
	rtSpecularLightTotal = vec4(specularLightTotal, 1.0);
}
