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
	
	a3_Demo_Curves_idle-update.c
	Demo mode implementations: curves & interpolation update.

	********************************************
	*** UPDATE FOR CURVE INTERP DEMO MODE    ***
	********************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_Demo_Curves.h"

//typedef struct a3_DemoState a3_DemoState;
#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoMacros.h"


//-----------------------------------------------------------------------------
// UPDATE

void a3curves_update(a3_DemoState* demoState, a3_Demo_Curves* demoMode, a3f64 dt)
{
	a3ui32 i;

	const a3_DemoProjector* activeCamera = demoState->projector + demoState->activeCamera;
	const a3_DemoSceneObject* activeCameraObject = activeCamera->sceneObject;
	a3_DemoPointLight* pointLight;

	a3_DemoModelMatrixStack matrixStack[demoStateMaxCount_sceneObject];

	// update matrix stack data
	for (i = 0; i < demoStateMaxCount_sceneObject; ++i)
	{
		a3demo_updateModelMatrixStack(matrixStack + i,
			activeCamera->projectionMat.m, activeCameraObject->modelMat.m, activeCameraObject->modelMatInv.m,
			(demoState->sceneObject + i)->modelMat.m, a3mat4_identity.m);
	}

	// send matrix stack data
	a3bufferRefill(demoState->ubo_transformStack_model, 0, sizeof(matrixStack), matrixStack);

	// send point light data
	pointLight = demoState->forwardPointLight;
	a3bufferRefill(demoState->ubo_pointLight, 0, demoState->forwardLightCount * sizeof(a3_DemoPointLight), pointLight);

	// send curve data
	i = a3bufferRefill(demoState->ubo_curveWaypoint, 0, sizeof(demoState->curveWaypoint), demoState->curveWaypoint);
	a3bufferRefillOffset(demoState->ubo_curveWaypoint, 0, i, sizeof(demoState->curveHandle), demoState->curveHandle);


	// update animation
	if (demoMode->interp)
	{
		a3ui32 k[4] = { 0 };
	//	a3vec4 m[2] = { 0 };

		// ****TO-DO: 
		//	-> update segment parameter
		//		-> if animating, increment segment time in range [0, duration)
		//		-> check if current segment time exceeded duration
		//			-> correct segment time & index accordingly
		//		-> update parameter in range [0, 1)
		// update controller
		
		//GOOD JOB STEPHEN :)

		const a3f32 dr = demoState->updateAnimation ? (a3f32)dt : 0.0f;

		demoState->segmentTime += dr;

		if (demoState->segmentTime >= demoState->segmentDuration)
		{
			demoState->segmentTime = 0.0f;
			demoState->segmentIndex++;
			if (demoState->segmentIndex >= demoState->segmentCount)
			{
				demoState->segmentIndex = 0;
			}
		}

		demoState->segmentParam = demoState->segmentTime * demoState->segmentDurationInv;



		// set key indices
		k[0] = i = demoState->segmentIndex;
		k[1] = (i + 1) % demoState->segmentCount;
		k[2] = (i + 2) % demoState->segmentCount;
		k[3] = (i + demoState->segmentCount - 1) % demoState->segmentCount;

		// ****TO-DO: 
		//	-> uncomment interpolation
		///*
		// perform position interpolation on current segment
		switch (demoMode->interp)
		{
		case curves_interpLerp:
			a3real3Lerp(demoState->sphereObject->position.v,
				demoState->curveWaypoint[k[0]].v,
				demoState->curveWaypoint[k[1]].v,
				demoState->segmentParam);
			break;
		case curves_interpBezier:
			a3real3Bezier3(demoState->sphereObject->position.v,
				demoState->curveWaypoint[k[0]].v,
				demoState->curveWaypoint[k[1]].v,
				demoState->curveWaypoint[k[2]].v,
				demoState->curveWaypoint[k[3]].v,
				demoState->segmentParam);
			break;
		case curves_interpCatmullRom:
			a3real3CatmullRom(demoState->sphereObject->position.v,
				demoState->curveWaypoint[k[3]].v,
				demoState->curveWaypoint[k[0]].v,
				demoState->curveWaypoint[k[1]].v,
				demoState->curveWaypoint[k[2]].v,
				demoState->segmentParam);
			break;
		case curves_interpCubicHermite:
			a3real3HermiteControl(demoState->sphereObject->position.v,
				demoState->curveWaypoint[k[0]].v,
				demoState->curveWaypoint[k[1]].v,
				demoState->curveHandle[k[0]].v,
				demoState->curveHandle[k[1]].v,
				demoState->segmentParam);
		//	a3real4Diff(m[0].v, demoState->curveHandle[k[0]].v, demoState->curveWaypoint[k[0]].v);
		//	a3real4Diff(m[1].v, demoState->curveHandle[k[1]].v, demoState->curveWaypoint[k[1]].v);
		//	a3real3HermiteTangent(demoState->sphereObject->position.v,
		//		demoState->curveWaypoint[k[0]].v,
		//		demoState->curveWaypoint[k[1]].v,
		//		m[0].v,
		//		m[1].v,
		//		demoState->segmentParam);
			break;
		}
		//*/
	}
	else
	{
		// reset position
		demoState->sphereObject->position = demoState->curveWaypoint[0].xyz;
	}
}


//-----------------------------------------------------------------------------
