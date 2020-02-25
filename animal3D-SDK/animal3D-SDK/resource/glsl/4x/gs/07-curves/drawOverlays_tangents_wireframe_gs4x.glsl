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
	
	drawOverlays_tangents_wireframe_gs4x.glsl
	Draw tangent bases of vertices and faces, and/or wireframe shapes, 
		based on flag passed to program.
*/

#version 430

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 or 8 wireframe verts = 28 or 32 verts)
#define MAX_VERTICES 32

// ****TO-DO: 
//	1) add input layout specifications
//	2) receive varying data from vertex shader
//	3) declare uniforms: 
//		-> projection matrix (inbound position is in view-space)
//		-> optional: wireframe color (can hard-code)
//		-> optional: size of tangent bases (ditto)
//		-> optional: flags to decide whether or not to draw bases/wireframe
//	4) declare output layout specifications
//	5) declare outbound color
//	6) draw tangent bases
//	7) draw wireframe

//1
layout (triangles) in;

//2	From fs 07 folder shader "PassTangentBasis"
in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
} vVertexData[];	//3 because triangle input

//Points:1
//Lines:2
//Triangles:3
//Line Adgasency?:4
//Triangle Adgasency?:5?

//4
layout (line_strip, max_vertices = MAX_VERTICES) out;

//5
out vec4 vColor;

//7
void drawWireFrame()
{
	vColor = vec4(1.0,0.5,0.0,1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	EndPrimitive();
}

void main()
{
	drawWireFrame();
}
