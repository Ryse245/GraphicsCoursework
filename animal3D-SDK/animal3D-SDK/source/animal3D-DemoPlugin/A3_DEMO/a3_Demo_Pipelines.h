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

	a3_Demo_Pipelines.h
	Demo mode interface: pipelines.

	********************************************
	*** THIS IS ONE DEMO MODE'S HEADER FILE  ***
	********************************************
*/

#ifndef __ANIMAL3D_DEMO_PIPELINES_H
#define __ANIMAL3D_DEMO_PIPELINES_H


//-----------------------------------------------------------------------------

#include "animal3D/animal3D.h"


//-----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C"
{
#else	// !__cplusplus
	typedef struct a3_Demo_Pipelines					a3_Demo_Pipelines;
	typedef enum a3_Demo_Pipelines_RenderProgramName	a3_Demo_Pipelines_RenderProgramName;
	typedef enum a3_Demo_Pipelines_DisplayProgramName	a3_Demo_Pipelines_DisplayProgramName;
	typedef enum a3_Demo_Pipelines_ActiveCameraName		a3_Demo_Pipelines_ActiveCameraName;
	typedef enum a3_Demo_Pipelines_PipelineName			a3_Demo_Pipelines_PipelineName;
	typedef enum a3_Demo_Pipelines_PassName				a3_Demo_Pipelines_PassName;
	typedef enum a3_Demo_Pipelines_TargetName			a3_Demo_Pipelines_TargetName;
#endif	// __cplusplus


//-----------------------------------------------------------------------------

	// scene object rendering program names
	enum a3_Demo_Pipelines_RenderProgramName
	{
		pipelines_renderPhong,			// Phong shading
		pipelines_renderPhongShadow,	// Phong shading with shadows

		pipelines_render_max
	};

	// final display modes
	enum a3_Demo_Pipelines_DisplayProgramName
	{
		pipelines_displayTexture,		// display simple texture
		pipelines_displayOutline,		// display texture with outlines

		pipelines_display_max
	};

	// active camera names
	enum a3_Demo_Pipelines_ActiveCameraName
	{
		pipelines_cameraSceneViewer,	// scene viewing camera
		pipelines_cameraShadowLight,	// shadow map capturing light

		pipelines_camera_max
	};


	// pipeline names
	enum a3_Demo_Pipelines_PipelineName
	{
		pipelines_forward,				// forward lighting pipeline
		pipelines_deferred_shading,		// deferred shading pipeline
		pipelines_deferred_lighting,	// deferred lighting pipeline

		pipelines_pipeline_max
	};

	// render passes
	enum a3_Demo_Pipelines_PassName
	{
		pipelines_passShadow,			// capture shadow map

		pipelines_passScene,			// render scene objects

		pipelines_passLighting,			// light pre-pass for deferred lighting

		pipelines_passComposite,		// composite for post-processing stage

		pipelines_passBright_2,			// bright pass for bloom (half screen size)
		pipelines_passBlurH_2,			// horizontal blur for bloom (half screen size)
		pipelines_passBlurV_2,			// horizontal blur for bloom (half screen size)
		pipelines_passBright_4,			// bright pass for bloom (quarter screen size)
		pipelines_passBlurH_4,			// horizontal blur for bloom (quarter screen size)
		pipelines_passBlurV_4,			// horizontal blur for bloom (quarter screen size)
		pipelines_passBright_8,			// bright pass for bloom (eighth screen size)
		pipelines_passBlurH_8,			// horizontal blur for bloom (eighth screen size)
		pipelines_passBlurV_8,			// horizontal blur for bloom (eighth screen size)
		pipelines_passBlend,			// bloom composite pass

		pipelines_passFractal_Mandelbrot,			//Midterm fractal passes
		pipelines_passFractal_Julia,
		pipelines_passFractal_Noise,
		pipelines_pass_max
	};

	// render target names
	enum a3_Demo_Pipelines_TargetName
	{
		pipelines_shadow_fragdepth = 0,		// fragment depth
		pipelines_target_shadow_max, 

		pipelines_scene_finalcolor = 0,		// final display color
		pipelines_scene_position,			// position attribute
		pipelines_scene_normal,				// normal attribute
		pipelines_scene_texcoord,			// texcoord attribute
		pipelines_scene_shadowcoord,		// shadow coordinate
		pipelines_scene_shadowtest,			// result of shadow test
		pipelines_scene_diffuseLight,		// diffuse light total
		pipelines_scene_specularLight,		// specular light total
		pipelines_scene_fragdepth,			// fragment depth
		pipelines_target_scene_max, 

		pipelines_composite_finalcolor = 0,	// final display color
		pipelines_composite_position,		// position attribute
		pipelines_composite_normal,			// normal attribute
		pipelines_composite_texcoord,		// texcoord attribute
		pipelines_composite_diffuseMap,		// diffuse map sample
		pipelines_composite_specularMap,	// specular map sample
		pipelines_composite_diffuseLight,	// diffuse light total
		pipelines_composite_specularLight,	// specular light total
		pipelines_target_composite_max,

		pipelines_bright_finalcolor = 0,	// final display color
		pipelines_bright_luminance,			// luminance of color
		pipelines_target_bright_max,

		pipelines_blur_finalcolor = 0,		// final display color
		pipelines_target_blur_max,

		pipelines_display_finalcolor = 0,	// final display color

		pipelines_display_fractal_mandelbrot,	//Midterm fractal targets
		pipelines_display_fractal_julia,
		pipelines_display_fractal_noise,
		pipelines_target_display_max,
	};


//-----------------------------------------------------------------------------

	// demo mode for basic shading
	struct a3_Demo_Pipelines
	{
		a3_Demo_Pipelines_RenderProgramName render;
		a3_Demo_Pipelines_DisplayProgramName display;
		a3_Demo_Pipelines_ActiveCameraName activeCamera;

		a3_Demo_Pipelines_PipelineName pipeline;
		a3_Demo_Pipelines_PassName pass;
		a3_Demo_Pipelines_TargetName targetIndex[pipelines_pass_max], targetCount[pipelines_pass_max];
	};


//-----------------------------------------------------------------------------


#ifdef __cplusplus
}
#endif	// __cplusplus


#endif	// !__ANIMAL3D_DEMO_PIPELINES_H