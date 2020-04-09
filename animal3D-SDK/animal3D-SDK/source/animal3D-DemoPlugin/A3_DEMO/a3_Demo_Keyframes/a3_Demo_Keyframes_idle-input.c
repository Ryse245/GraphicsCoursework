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

	a3_Demo_Keyframes_idle-input.c
	Demo mode implementations: curves & interpolation input.

	********************************************
	*** INPUT PROCESS FOR CURVE INTERP MODE  ***
	********************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_Demo_Keyframes.h"

//typedef struct a3_DemoState a3_DemoState;
#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoMacros.h"


//-----------------------------------------------------------------------------
// CALLBACKS

// main demo mode callback
void a3keyframesCB_input_keyCharPress(a3_DemoState const* demoState, a3_Demo_Keyframes* demoMode, a3i32 asciiKey)
{
	switch (asciiKey)
	{
		// toggle render program
		a3demoCtrlCasesLoop(demoMode->render, keyframes_render_max, 'k', 'j');

		// toggle display program
		a3demoCtrlCasesLoop(demoMode->display, keyframes_display_max, 'K', 'J');

		// toggle active camera
		a3demoCtrlCasesLoop(demoMode->activeCamera, keyframes_camera_max, 'v', 'c');

		// toggle interpolation mode
		a3demoCtrlCasesLoop(demoMode->interp, keyframes_interp_max, 'V', 'C');

		// toggle pipeline mode
		a3demoCtrlCasesLoop(demoMode->pipeline, keyframes_pipeline_max, ']', '[');

		// toggle target
		a3demoCtrlCasesLoop(demoMode->targetIndex[demoMode->pass], demoMode->targetCount[demoMode->pass], '}', '{');

		// toggle pass to display
	//	a3demoCtrlCasesLoop(demoMode->pass, keyframes_pass_max, ')', '(');
	case ')':
		a3demoCtrlIncLoop(demoMode->pass, keyframes_pass_max);
	case 'I':	// if toggle is switched, do the following
		if (demoState->skipIntermediatePasses)
		{
			a3demoCtrlIncClamp(demoMode->pass, keyframes_passBlend, keyframes_passComposite);
			a3demoCtrlIncClamp(demoMode->pass, keyframes_passComposite, keyframes_passScene);
			a3demoCtrlIncClamp(demoMode->pass, keyframes_passScene, -1);
		}
		break;
	case '(':
		a3demoCtrlDecLoop(demoMode->pass, keyframes_pass_max);
		if (demoState->skipIntermediatePasses)
		{
			a3demoCtrlDecClamp(demoMode->pass, keyframes_passBlend, keyframes_passComposite);
			a3demoCtrlDecClamp(demoMode->pass, keyframes_passComposite, keyframes_passScene);
			a3demoCtrlDecClamp(demoMode->pass, keyframes_passScene, -1);
			demoMode->pass = (demoMode->pass + keyframes_pass_max) % keyframes_pass_max;
		}
		break;
	}


	// skip passes if not on the correct pipeline
	switch (asciiKey)
	{
	case ']':
	case '[':
	case ')':
		break;
	case '(':
		break;
	}


	// animation controls
	switch (asciiKey)
	{
	case '0':
		demoMode->editingJoint = !demoMode->editingJoint;
		break;

	case '9':
		if (demoMode->editingJoint)
			demoMode->editJointIndex = (demoMode->editJointIndex + 1) % demoState->hierarchy_skel[demoMode->editSkeletonIndex].numNodes;
		break;
	case '8':
		if (demoMode->editingJoint)
			demoMode->editJointIndex = (demoMode->editJointIndex + demoState->hierarchy_skel[demoMode->editSkeletonIndex].numNodes - 1) % demoState->hierarchy_skel[demoMode->editSkeletonIndex].numNodes;
		break;
	}
}


void a3keyframesCB_input_keyCharHold(a3_DemoState const* demoState, a3_Demo_Keyframes* demoMode, a3i32 asciiKey)
{
	// individual DOF editing
	if (demoMode->editingJoint)
	{
		a3_HierarchyNodePose* currentNodePose = demoState->hierarchyState_skel[demoMode->editSkeletonIndex].poseGroup->pose[1].nodePose + demoMode->editJointIndex;
		const a3_HierarchyPoseFlag currentPoseFlag = demoState->hierarchyPoseFlag_skel[demoMode->editSkeletonIndex][demoMode->editJointIndex];
		const a3boolean doesRotate = currentPoseFlag & a3poseFlag_rotate;
		const a3boolean doesTranslate = currentPoseFlag & a3poseFlag_translate;
		const a3real rotateRate = a3real_half;
		const a3real translateRate = a3real_quarter;

		switch (asciiKey)
		{
			// sub rotate x
		case '1':
			if (doesRotate)
				currentNodePose->orientation.x = a3trigValid_sind(currentNodePose->orientation.x - rotateRate);
			break;
			// add rotate x
		case '!':
			if (doesRotate)
				currentNodePose->orientation.x = a3trigValid_sind(currentNodePose->orientation.x + rotateRate);
			break;
			// sub rotate y
		case '2':
			if (doesRotate)
				currentNodePose->orientation.y = a3trigValid_sind(currentNodePose->orientation.y - rotateRate);
			break;
			// add rotate y
		case '@':
			if (doesRotate)
				currentNodePose->orientation.y = a3trigValid_sind(currentNodePose->orientation.y + rotateRate);
			break;
			// sub rotate z
		case '3':
			if (doesRotate)
				currentNodePose->orientation.z = a3trigValid_sind(currentNodePose->orientation.z - rotateRate);
			break;
			// add rotate z
		case '#':
			if (doesRotate)
				currentNodePose->orientation.z = a3trigValid_sind(currentNodePose->orientation.z + rotateRate);
			break;

			// sub translate x
		case '4':
			if (doesTranslate)
				currentNodePose->translation.x -= translateRate;
			break;
			// add translate x
		case '$':
			if (doesTranslate)
				currentNodePose->translation.x += translateRate;
			break;
			// sub translate y
		case '5':
			if (doesTranslate)
				currentNodePose->translation.y -= translateRate;
			break;
			// add translate y
		case '%':
			if (doesTranslate)
				currentNodePose->translation.y += translateRate;
			break;
			// sub translate z
		case '6':
			if (doesTranslate)
				currentNodePose->translation.z -= translateRate;
			break;
			// add translate z
		case '^':
			if (doesTranslate)
				currentNodePose->translation.z += translateRate;
			break;
		}
	}
}


//-----------------------------------------------------------------------------
