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
	
	a3_DemoState_idle-input.c/.cpp
	Demo state function implementations.

	****************************************************
	*** THIS IS ONE OF YOUR DEMO'S MAIN SOURCE FILES ***
	*** Implement your demo logic pertaining to      ***
	***     HANDLING INPUT in this file.             ***
	****************************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoMacros.h"


//-----------------------------------------------------------------------------
// INPUT SUB-ROUTINES

// main input processing for scene
void a3demo_input_scene(a3_DemoState *demoState, a3f64 dt)
{
	a3real ctrlRotateSpeed = 1.0f;
	a3real azimuth = 0.0f;
	a3real elevation = 0.0f;
	a3boolean rotatingCamera = 0, movingCamera = 0, changingParam = 0;
	a3_DemoProjector *activeCamera = demoState->projector + demoState->activeCamera;
	a3_DemoSceneObject* activeCameraObject = activeCamera->sceneObject;


	// using Xbox controller
	if (a3XboxControlIsConnected(demoState->xcontrol))
	{
		// move and rotate camera using joysticks
		a3f64 lJoystick[2], rJoystick[2], lTrigger[1], rTrigger[1];
		a3XboxControlGetJoysticks(demoState->xcontrol, lJoystick, rJoystick);
		a3XboxControlGetTriggers(demoState->xcontrol, lTrigger, rTrigger);

		movingCamera = a3demo_moveSceneObject(activeCameraObject, (a3f32)dt * activeCamera->ctrlMoveSpeed,
			(a3real)(rJoystick[0]),
			(a3real)(*rTrigger - *lTrigger),
			(a3real)(-rJoystick[1])
		);
		// rotate
		{
			ctrlRotateSpeed = 10.0f;
			azimuth = (a3real)(-lJoystick[0]);
			elevation = (a3real)(lJoystick[1]);

			// this really defines which way is "up"
			// mouse's Y motion controls pitch, but X can control yaw or roll
			// controlling yaw makes Y axis seem "up", roll makes Z seem "up"
			rotatingCamera = a3demo_rotateSceneObject(activeCameraObject,
				ctrlRotateSpeed * (a3f32)dt * activeCamera->ctrlRotateSpeed,
				// pitch: vertical tilt
				elevation,
				// yaw/roll depends on "vertical" axis: if y, yaw; if z, roll
				demoState->verticalAxis ? azimuth : a3real_zero,
				demoState->verticalAxis ? a3real_zero : azimuth);
		}
	}

	// using mouse and keyboard
	else
	{
		// move using WASDEQ
		movingCamera = a3demo_moveSceneObject(activeCameraObject, (a3f32)dt * activeCamera->ctrlMoveSpeed,
			(a3real)a3keyboardGetDifference(demoState->keyboard, a3key_D, a3key_A),
			(a3real)a3keyboardGetDifference(demoState->keyboard, a3key_E, a3key_Q),
			(a3real)a3keyboardGetDifference(demoState->keyboard, a3key_S, a3key_W)
		);
		if (a3mouseIsHeld(demoState->mouse, a3mouse_left))
		{
			azimuth = -(a3real)a3mouseGetDeltaX(demoState->mouse);
			elevation = -(a3real)a3mouseGetDeltaY(demoState->mouse);

			// this really defines which way is "up"
			// mouse's Y motion controls pitch, but X can control yaw or roll
			// controlling yaw makes Y axis seem "up", roll makes Z seem "up"
			rotatingCamera = a3demo_rotateSceneObject(activeCameraObject,
				ctrlRotateSpeed * (a3f32)dt * activeCamera->ctrlRotateSpeed,
				// pitch: vertical tilt
				elevation,
				// yaw/roll depends on "vertical" axis: if y, yaw; if z, roll
				demoState->verticalAxis ? azimuth : a3real_zero,
				demoState->verticalAxis ? a3real_zero : azimuth);
		}
	}
}


//-----------------------------------------------------------------------------
// INPUT

void a3demo_input(a3_DemoState *demoState, a3f64 dt)
{
	// shared input processing for scene
	a3demo_input_scene(demoState, dt);

	// input processing based on mode
	switch (demoState->demoMode)
	{
	case demoState_shading:
		demoState->activeCamera = demoState->demoMode_shading->activeCamera;
		break;
	case demoState_pipelines:
		demoState->activeCamera = demoState->demoMode_pipelines->activeCamera;
		break;
	case demoState_curves:
		demoState->activeCamera = demoState->demoMode_curves->activeCamera;
		break;
	}
}


//-----------------------------------------------------------------------------
// CALLBACKS

// demo mode callbacks
void a3shadingCB_input_keyCharPress(a3_DemoState const* demoState, a3_Demo_Shading* demoMode, a3i32 asciiKey);
void a3pipelinesCB_input_keyCharPress(a3_DemoState const* demoState, a3_Demo_Pipelines* demoMode, a3i32 asciiKey);
void a3curvesCB_input_keyCharPress(a3_DemoState const* demoState, a3_Demo_Curves* demoMode, a3i32 asciiKey);

// ascii key callback
void a3demoCB_input_keyCharPress(a3_DemoState* demoState, a3i32 asciiKey)
{
	switch (asciiKey)
	{
		// change pipeline mode
		a3demoCtrlCasesLoop(demoState->demoMode, demoState_mode_max, '>', '<');
		a3demoCtrlCasesLoop(demoState->demoMode, demoState_mode_max, '.', ',');


		// increase/decrease light count
		a3demoCtrlCasesCap(demoState->forwardLightCount, demoStateMaxCount_lightObject, 0, 'L', 'l');
		a3demoCtrlCasesCap(demoState->deferredLightCount, demoStateMaxCount_lightVolume, 0, ':', ';');

		//Control number of iterations for fractals
		a3demoCtrlCasesCap(demoState->fractalNumIterations, demoStateMaxCount_fractalIterations, 1, '#', '@');
		//Control number of zooms in fractal
		a3demoCtrlCasesCap(demoState->fractalNumZoom, demoStateMaxCount_fractalZoom, 0, 'N', 'n');


		// toggle grid
		a3demoCtrlCaseToggle(demoState->displayGrid, 'g');

		// toggle skybox
		a3demoCtrlCaseToggle(demoState->displaySkybox, 'b');

		// toggle hidden volumes
		a3demoCtrlCaseToggle(demoState->displayHiddenVolumes, 'h');

		// toggle pipeline overlay
		a3demoCtrlCaseToggle(demoState->displayPipeline, 'o');

		// toggle world axes
		a3demoCtrlCaseToggle(demoState->displayWorldAxes, 'x');

		// toggle object axes
		a3demoCtrlCaseToggle(demoState->displayObjectAxes, 'z');

		// toggle tangent bases on vertices or other
		a3demoCtrlCaseToggle(demoState->displayTangentBases, 'B');

		// toggle wireframe overlay
		a3demoCtrlCaseToggle(demoState->displayWireframe, 'F');

		// update animation
		a3demoCtrlCaseToggle(demoState->updateAnimation, 'm');

		// toggle stencil test
		a3demoCtrlCaseToggle(demoState->stencilTest, 'i');

		// toggle stencil test
		a3demoCtrlCaseToggle(demoState->skipIntermediatePasses, 'I');
	}


	// callback for current mode
	switch (demoState->demoMode)
	{
	case demoState_shading:
		a3shadingCB_input_keyCharPress(demoState, demoState->demoMode_shading, asciiKey);
		break;
	case demoState_pipelines:
		a3pipelinesCB_input_keyCharPress(demoState, demoState->demoMode_pipelines, asciiKey);
		break;
	case demoState_curves:
		a3curvesCB_input_keyCharPress(demoState, demoState->demoMode_curves, asciiKey);
		break;
	}
}

// ascii key hold callback
void a3demoCB_input_keyCharHold(a3_DemoState* demoState, a3i32 asciiKey)
{
	switch (asciiKey)
	{
		// increase/decrease light count
		a3demoCtrlCasesCap(demoState->deferredLightCount, demoStateMaxCount_lightVolume, 0, ':', ';');
		a3demoCtrlCasesCap(demoState->fractalNumIterations, demoStateMaxCount_fractalIterations, 1, '#', '@');
		a3demoCtrlCasesCap(demoState->fractalNumZoom, demoStateMaxCount_fractalZoom, 0, 'N', 'n');
	}


	// callback for current mode
	switch (demoState->demoMode)
	{
	case demoState_shading:
		break;
	case demoState_pipelines:
		break;
	case demoState_curves:
		break;
	}
}


//-----------------------------------------------------------------------------
