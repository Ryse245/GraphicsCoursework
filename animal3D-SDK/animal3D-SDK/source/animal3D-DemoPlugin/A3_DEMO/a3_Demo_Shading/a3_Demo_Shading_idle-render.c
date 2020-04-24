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

	a3_DemoShading_idle-render.c
	Demo mode implementations: shading rendering.

	********************************************
	*** RENDERING CODE FOR SHADING DEMO MODE ***
	********************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_Demo_Shading.h"

#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoRenderUtils.h"


// OpenGL
#ifdef _WIN32
#include <gl/glew.h>
#include <Windows.h>
#include <GL/GL.h>
#else	// !_WIN32
#include <OpenGL/gl3.h>
#endif	// _WIN32


//-----------------------------------------------------------------------------

// controls for shading mode
void a3shading_render_controls(a3_DemoState const* demoState, a3_Demo_Shading const* demoMode,
	a3f32 const textAlign, a3f32 const textDepth, a3f32 const textOffsetDelta, a3f32 textOffset)
{
	// display mode info
	a3byte const* pipelineText[shading_pipeline_max] = {
		"Shading",
		"Shading with MRT",
	};
	a3byte const* targetText_back[shading_target_back_max] = {
		"Color buffer",
	};
	a3byte const* targetText_fbo[shading_target_fbo_max] = {
		"Color target 0: FINAL SCENE COLOR",
		"Color target 1: Attrib data: view position",
		"Color target 2: Attrib data: view normal",
		"Color target 3: Attrib data: atlas texcoord",
		"Color target 4: Texture: diffuse map",
		"Color target 5: Texture: specular map",
		"Color target 6: Lighting: diffuse total",
		"Color target 7: Lighting: specular total",
		"Depth buffer",
	};
	a3byte const* const* targetText[shading_pipeline_max] = {
		targetText_back,
		targetText_fbo,
	};

	// forward pipeline names
	a3byte const* renderProgramName[shading_render_max] = {
		"Solid color",
		"Texturing",
		"Lambert shading",
		"Phong shading",
		"Nonphotorealistic shading",
	};

	// forward display names
	a3byte const* displayProgramName[shading_display_max] = {
		"Texture",
		"Color manipulation",
		"Texcoord manipulation",
	};

	// text color
	a3vec4 const col = { a3real_half, a3real_zero, a3real_half, a3real_one };

	// pipeline and target
	a3_Demo_Shading_RenderProgramName const render = demoMode->render;
	a3_Demo_Shading_DisplayProgramName const display = demoMode->display;
	a3_Demo_Shading_PipelineName const pipeline = demoMode->pipeline;
	a3_Demo_Shading_TargetName const targetIndex = demoMode->targetIndex[pipeline];
	a3_Demo_Shading_TargetName const targetCount = demoMode->targetCount[pipeline];

	// demo modes
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"    Pipeline (%u / %u) ('[' | ']'): %s", pipeline + 1, shading_pipeline_max, pipelineText[pipeline]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"        Target (%u / %u) ('{' | '}'): %s", targetIndex + 1, targetCount, targetText[pipeline][targetIndex]);

	// lighting modes
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"    Rendering mode (%u / %u) ('j' | 'k'): %s", render + 1, shading_render_max, renderProgramName[render]);

	// specific modes
	if (pipeline == shading_fbo)
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    Display mode (%u / %u) ('J' | 'K'): %s", display + 1, shading_display_max, displayProgramName[display]);
}


//-----------------------------------------------------------------------------

// sub-routine for rendering the demo state using the shading pipeline
void a3shading_render(a3_DemoState const* demoState, a3_Demo_Shading const* demoMode)
{
	// pointers
	const a3_VertexDrawable* currentDrawable;
	const a3_DemoStateShaderProgram* currentDemoProgram;
	const a3_DemoPointLight* pointLight;

	// framebuffers
	const a3_Framebuffer* currentWriteFBO, * currentDisplayFBO;

	// indices
	a3ui32 i, j, k;

	// RGB
	const a3vec4 rgba4[] = {
		{ 1.0f, 0.0f, 0.0f, 1.0f },	// red
		{ 0.0f, 1.0f, 0.0f, 1.0f },	// green
		{ 0.0f, 0.0f, 1.0f, 1.0f },	// blue
		{ 0.0f, 1.0f, 1.0f, 1.0f },	// cyan
		{ 1.0f, 0.0f, 1.0f, 1.0f },	// magenta
		{ 1.0f, 1.0f, 0.0f, 1.0f },	// yellow
		{ 1.0f, 0.5f, 0.0f, 1.0f },	// orange
		{ 0.0f, 0.5f, 1.0f, 1.0f },	// sky blue
		{ 0.5f, 0.5f, 0.5f, 1.0f },	// solid grey
		{ 0.5f, 0.5f, 0.5f, 0.5f },	// translucent grey
	};
	const a3real
		* const red = rgba4[0].v, * const green = rgba4[1].v, * const blue = rgba4[2].v,
		* const cyan = rgba4[3].v, * const magenta = rgba4[4].v, * const yellow = rgba4[5].v,
		* const orange = rgba4[6].v, * const skyblue = rgba4[7].v,
		* const grey = rgba4[8].v, * const grey_t = rgba4[9].v;

	// camera used for drawing
	const a3_DemoProjector* activeCamera = demoState->sceneCamera;
	const a3_DemoSceneObject* activeCameraObject = activeCamera->sceneObject;

	// current scene object being rendered, for convenience
	const a3_DemoSceneObject* currentSceneObject, * endSceneObject;

	// temp drawable pointers
	const a3_VertexDrawable* drawable[] = {
		demoState->draw_plane,
		demoState->draw_sphere,
		demoState->draw_cylinder,
		demoState->draw_torus,
		demoState->draw_teapot,
	};

	// temp texture pointers
	const a3_Texture* texture_dm[] = {
		demoState->tex_stone_dm,
		demoState->tex_earth_dm,
		demoState->tex_stone_dm,
		demoState->tex_mars_dm,
		demoState->tex_checker,
	};
	const a3_Texture* texture_sm[] = {
		demoState->tex_stone_dm,
		demoState->tex_earth_sm,
		demoState->tex_stone_dm,
		demoState->tex_mars_sm,
		demoState->tex_checker,
	};

	// forward pipeline shader programs
	const a3_DemoStateShaderProgram* renderProgram[shading_pipeline_max][shading_render_max] = {
		{
			demoState->prog_drawColorUnif,
			demoState->prog_drawTexture,
			demoState->prog_drawLambert_multi,
			demoState->prog_drawPhong_multi,
			demoState->prog_drawNonphoto_multi,
		}, {
			demoState->prog_drawColorUnif,
			demoState->prog_drawTexture_mrt,
			demoState->prog_drawLambert_multi_mrt,
			demoState->prog_drawPhong_multi_mrt,
			demoState->prog_drawNonphoto_multi_mrt,
		},
	};

	// display shader programs
	const a3_DemoStateShaderProgram* displayProgram[shading_pipeline_max][shading_display_max] = {
		{
			0,
		}, {
			demoState->prog_drawTexture,
			demoState->prog_drawTexture_colorManip,
			demoState->prog_drawTexture_coordManip,
		},
	};

	// framebuffers to which to write based on pipeline mode
	const a3_Framebuffer* writeFBO[shading_pipeline_max] = {
		0,
		demoState->fbo_scene_c16d24s8_mrt,
	};

	// target info for current pipeline mode
	a3_Demo_Shading_RenderProgramName const render = demoMode->render;
	a3_Demo_Shading_DisplayProgramName const display = demoMode->display;
	a3_Demo_Shading_PipelineName const pipeline = demoMode->pipeline;
	a3_Demo_Shading_TargetName const targetIndex = demoMode->targetIndex[pipeline], targetCount = demoMode->targetCount[pipeline];


	// tmp lighting data
	a3f32 lightSz[demoStateMaxCount_lightObject];
	a3f32 lightSzInvSq[demoStateMaxCount_lightObject];
	a3vec4 lightPos[demoStateMaxCount_lightObject];
	a3vec4 lightCol[demoStateMaxCount_lightObject];

	// final model matrix and full matrix stack
	a3mat4 viewMat = activeCameraObject->modelMatInv;
	a3mat4 viewProjectionMat = activeCamera->viewProjectionMat;
	a3mat4 modelViewProjectionMat = viewProjectionMat;
	a3mat4 modelViewMat = a3mat4_identity, modelMat = a3mat4_identity;


	//-------------------------------------------------------------------------
	// 1) SCENE PASS: render scene with desired shader
	//	- activate scene framebuffer
	//	- draw scene
	//		- clear buffers
	//		- render shapes using appropriate shaders
	//		- capture color and depth

	// select target framebuffer
	switch (pipeline)
	{
		// shading
	case shading_back:
		// target back buffer (default)
		a3framebufferDeactivateSetViewport(a3fbo_depth24_stencil8,
			-demoState->frameBorder, -demoState->frameBorder, demoState->frameWidth, demoState->frameHeight);

		// skybox or regular clear
		glDisable(GL_STENCIL_TEST);
		glDisable(GL_BLEND);

		// clearing is expensive!
		// only call clear if skybox is not used at all; 
		//	skybox will draw over everything otherwise
		// change depth mode to 'always' to ensure box gets drawn and resets depth
		glDepthFunc(GL_ALWAYS);
		currentDemoProgram = demoState->displaySkybox ? demoState->prog_drawTexture : demoState->prog_drawColorUnif;
		a3demo_drawModelTexturedColored_invertModel(modelViewProjectionMat.m, viewProjectionMat.m, demoState->skyboxObject->modelMat.m, a3mat4_identity.m, currentDemoProgram, demoState->draw_skybox, demoState->tex_skybox_clouds, skyblue);
		glDepthFunc(GL_LEQUAL);
		break;

		// shading with MRT FBO
	case shading_fbo:
		// target scene framebuffer
		currentWriteFBO = writeFBO[pipeline];
		a3demo_setSceneState(currentWriteFBO, demoState->displaySkybox);
		break;
	}


	// optional stencil test before drawing objects
	a3real4x4SetScale(modelMat.m, a3real_four);
	if (demoState->stencilTest)
		a3demo_drawStencilTest(modelViewProjectionMat.m, viewProjectionMat.m, modelMat.m, demoState->prog_drawColorUnif, demoState->draw_sphere);


	// copy temp light data
	for (k = 0, pointLight = demoState->forwardPointLight;
		k < demoState->forwardLightCount;
		++k, ++pointLight)
	{
		lightSz[k] = pointLight->radius;
		lightSzInvSq[k] = pointLight->radiusInvSq;
		lightPos[k] = pointLight->viewPos;
		lightCol[k] = pointLight->color;
	}


	// support multiple geometry passes
	for (i = 0, j = 1; i < j; ++i)
	{
		// select forward algorithm
		switch (i)
		{
			// forward pass
		case 0: {
			// select program based on settings
			currentDemoProgram = renderProgram[pipeline][render];
			a3shaderProgramActivate(currentDemoProgram->program);

			// send shared data: 
			//	- projection matrix
			//	- light data
			//	- activate shared textures including atlases if using
			//	- shared animation data
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP, 1, activeCamera->projectionMat.mm);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP_inv, 1, activeCamera->projectionMatInv.mm);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uAtlas, 1, a3mat4_identity.mm);
			a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, skyblue);
			a3shaderUniformSendInt(a3unif_single, currentDemoProgram->uLightCt, 1, &demoState->forwardLightCount);
			a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uLightSz, demoState->forwardLightCount, lightSz);
			a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uLightSzInvSq, demoState->forwardLightCount, lightSzInvSq);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightPos, demoState->forwardLightCount, lightPos->v);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightCol, demoState->forwardLightCount, lightCol->v);
			a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);	//Added
			a3textureActivate(demoState->tex_ramp_dm, a3tex_unit04);
			a3textureActivate(demoState->tex_ramp_sm, a3tex_unit05);
			a3textureActivate(demoState->tex_gradient, a3tex_unit06);

			// individual object requirements: 
			//	- modelviewprojection
			//	- modelview
			//	- modelview for normals
			//	- per-object animation data
			for (k = 0,
				currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject;
				currentSceneObject <= endSceneObject;
				++k, ++currentSceneObject)
			{
				a3textureActivate(texture_dm[k], a3tex_unit00);
				a3textureActivate(texture_sm[k], a3tex_unit01);
				a3demo_drawModelLighting(modelViewProjectionMat.m, modelViewMat.m, viewProjectionMat.m, viewMat.m, currentSceneObject->modelMat.m, currentDemoProgram, drawable[k], rgba4[k + 3].v);
			}
		}	break;
			// end geometry pass
		}
	}


	// stop using stencil
	if (demoState->stencilTest)
		glDisable(GL_STENCIL_TEST);


	// draw grid aligned to world
	if (demoState->displayGrid)
		a3demo_drawModelSolidColor(modelViewProjectionMat.m, viewProjectionMat.m, demoState->gridTransform.m, demoState->prog_drawColorUnif, demoState->draw_grid, demoState->gridColor.v);


	//-------------------------------------------------------------------------
	// PREPARE FOR POST-PROCESSING
	//	- double buffer swap (if applicable)
	//	- ensure blending is disabled
	//	- re-activate FSQ drawable IF NEEDED (i.e. changed in previous step)
	glDisable(GL_BLEND);
	currentDrawable = demoState->draw_unitquad;
	a3vertexDrawableActivate(currentDrawable);


	//-------------------------------------------------------------------------
	// DISPLAY: final pass, perform and present final composite
	//	- finally draw to back buffer
	//	- select display texture(s)
	//	- activate final pass program
	//	- draw final FSQ

	// revert to back buffer and disable depth testing
	a3framebufferDeactivateSetViewport(a3fbo_depthDisable,
		-demoState->frameBorder, -demoState->frameBorder, demoState->frameWidth, demoState->frameHeight);

	// select framebuffer to display based on mode
	currentDisplayFBO = writeFBO[pipeline];

	// select output to display
	switch (pipeline)
	{
		// no framebuffer active for scene render
	case shading_back:
		// do nothing
		break;

		// scene was rendered to framebuffer
	case shading_fbo:
		// composite skybox
		currentDemoProgram = demoState->displaySkybox ? demoState->prog_drawTexture : demoState->prog_drawColorUnif;
		a3demo_drawModelTexturedColored_invertModel(modelViewProjectionMat.m, viewProjectionMat.m, demoState->skyboxObject->modelMat.m, a3mat4_identity.m, currentDemoProgram, demoState->draw_skybox, demoState->tex_skybox_clouds, skyblue);
		a3demo_enableCompositeBlending();

		// select output to display
		if (currentDisplayFBO->color && (!currentDisplayFBO->depthStencil || targetIndex < targetCount - 1))
			a3framebufferBindColorTexture(currentDisplayFBO, a3tex_unit00, targetIndex);
		else
			a3framebufferBindDepthTexture(currentDisplayFBO, a3tex_unit00);
		break;
	}


	// final display: activate desired final program and draw FSQ
	if (currentDisplayFBO)
	{
		// prepare for final draw
		currentDrawable = demoState->draw_unitquad;
		a3vertexDrawableActivate(currentDrawable);

		// determine if additional passes are required
		currentDemoProgram = displayProgram[pipeline][display];
		a3shaderProgramActivate(currentDemoProgram->program);

		// done
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, a3mat4_identity.mm);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uAtlas, 1, a3mat4_identity.mm);
		a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);
		a3vertexDrawableRenderActive();
	}


	//-------------------------------------------------------------------------
	// OVERLAYS: done after FSQ so they appear over everything else
	//	- disable depth testing
	//	- draw overlays appropriately

	// hidden volumes
	if (demoState->displayHiddenVolumes)
	{
		glCullFace(GL_FRONT);

		// draw light volumes
		currentDemoProgram = demoState->prog_drawColorUnif;
		a3shaderProgramActivate(currentDemoProgram->program);
		a3vertexDrawableActivate(demoState->draw_pointlight);
		for (k = 0; k < demoState->forwardLightCount; ++k)
		{
			a3real4x4SetScale(modelMat.m, (a3real)0.0075 * demoState->forwardPointLight[k].radius);
			modelMat.v3 = demoState->forwardPointLight[k].worldPos;
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, demoState->forwardPointLight[k].color.v);
			a3demo_drawModelSimple(modelViewProjectionMat.m, viewProjectionMat.m, modelMat.m, currentDemoProgram);
		}

		glCullFace(GL_BACK);
	}


	// superimpose axes
	// draw coordinate axes in front of everything
	currentDemoProgram = demoState->prog_drawColorAttrib;
	a3shaderProgramActivate(currentDemoProgram->program);
	a3vertexDrawableActivate(demoState->draw_axes);

	// center of world from current viewer
	// also draw other viewer/viewer-like object in scene
	if (demoState->displayWorldAxes)
	{
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, viewProjectionMat.mm);
		a3vertexDrawableRenderActive();
	}

	// individual objects
	if (demoState->displayObjectAxes)
	{
		a3_DemoSceneObject const* axesObjects[] = {
			demoState->planeObject, demoState->sphereObject, demoState->cylinderObject, demoState->torusObject, demoState->teapotObject,
			demoState->mainLightObject, demoState->mainCameraObject,
			0
		}, ** axesObjectsItr = axesObjects;
		for (currentSceneObject = *axesObjectsItr,
			endSceneObject = demoState->displayHiddenVolumes ? 0 : demoState->mainLightObject;
			currentSceneObject != endSceneObject;
			currentSceneObject = *(++axesObjectsItr))
			a3demo_drawModelSimple(modelViewProjectionMat.m, viewProjectionMat.m, currentSceneObject->modelMat.m, currentDemoProgram);
	}
}


//-----------------------------------------------------------------------------
