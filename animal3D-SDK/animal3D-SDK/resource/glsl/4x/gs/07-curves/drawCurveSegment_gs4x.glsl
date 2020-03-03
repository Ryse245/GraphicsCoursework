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
	
	drawCurveSegment_gs4x.glsl
	Draw curve segment based on waypoints being passed from application.
*/

#version 430

// (16 samples/segment * 1 segment + 4 samples/handle * 2 handles)
#define MAX_VERTICES 24

#define MAX_WAYPOINTS 32

// ****TO-DO: 
//	1) add input layout specifications
//	2) receive varying data from vertex shader
//	3) declare uniforms: 
//		-> model-view-projection matrix (no inbound position at all)
//		-> flag to select curve type
//		-> optional: segment index and count
//		-> optional: curve color (can hard-code)
//		-> optional: other animation data
//	4) declare output layout specifications
//	5) declare outbound color
//	6) write interpolation functions to help with sampling
//	7) select curve type and sample over [0, 1] interval
layout (points) in;

layout (line_strip, max_vertices = MAX_VERTICES) out;

uniform mat4 uMVP;
uniform vec4 uColor;
uniform float uTime;
uniform int uIndex;
uniform int uCount;
uniform int uFlag;
uniform mat4 ubo_curveWaypoint;

//int k[4];

out vec4 vColor;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
} vVertexData[];


void drawTest()
{
	vColor = vec4(1,0,0,1);
	/*
	gl_Position = ubo_curveWaypoint[0];
	EmitVertex();
	gl_Position = ubo_curveWaypoint[1];
	EmitVertex();
	EndPrimitive();
	*/

}
void main()
{
	/*
	k[0] = uIndex;
	k[1] = (uIndex + 1) % uCount;
	k[2] = (uIndex + 2) % uCount;
	k[2] = (uIndex + uCount-1) % uCount;
	*/
	drawTest();
}
