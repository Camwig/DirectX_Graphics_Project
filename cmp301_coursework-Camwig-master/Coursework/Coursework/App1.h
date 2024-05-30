// Application.h
#ifndef _APP1_H
#define _APP1_H

// Includes all the appropriate headers and files
#include "DXF.h"// include dxframework
#include "ManipulationShader.h"
#include "LightShader.h"
#include "Terrain_Shader.h"
#include "Water_Shader.h"
#include "Geometry_shader.h"

#include "ShadowShader.h"
#include "DepthShader.h"
#include "TerrainDepth.h"
#include "WaterDepth.h"
#include "HorizontalBlurShader.h"
#include "VerticalBlurShader.h"
#include "CompositeShader.h"
#include "TextureShader.h"
#include "TesselationShader.h"
#include <algorithm>

#include <cmath>

//Defines the number of lights in the scene
#define NUM_LIGHTS 4

class App1 : public BaseApplication
{
public:
	//Public functions
	App1();
	~App1();
	void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN);
	bool frame();

protected:
	//Protected functions
	bool render();
	void depthPass();
	void HorizontalPass();
	void VerticalPass();
	void CompositePass();
	void finalPass();
	void firstPass();
	void BasePass();
	void gui();

private:
	//Pointers to classes
	Terrain_Shader* this_shader;
	ManipulationShader* shader;
	Water_Shader* watershader;
	ShadowShader* shadowShader;
	TextureShader* textureShader;
	TesselationShader* tessShader;
	DepthShader* depthShader;
	TerrainDepth* terrain_d;
	WaterDepth* water_d;
	HorizontalBlurShader* horizontal_blur;
	VerticalBlurShader* vertical_blur;
	CompositeShader* composite_pass;

	//Pointerss to mesh
	AModel* Alex_model;
	AModel* Fire_gem_model[2];
	PlaneMesh* terrain_mesh;
	PlaneMesh* flat_mesh;
	PlaneMesh* water_mesh;
	PointMesh* triangle;
	QuadMesh* quad;
	TessellationMesh* tess_mesh;

	//Pointer to light class
	Light* light[NUM_LIGHTS];

	//Pointers to the shadowmaps
	ShadowMap* shadowMap[NUM_LIGHTS];
	ShadowMap* depthmap;

	//Pointers to render texture 
	RenderTexture* renderTexture;
	RenderTexture* horizontalBlurTexture;
	RenderTexture* verticalBlurTexture;
	RenderTexture* compositeTexture;

	//Pointers to Orthomesh
	OrthoMesh* orthoMesh;
	OrthoMesh* orthoMesh2;
	OrthoMesh* UpMesh;
	OrthoMesh* sampleMesh;

	//Initialise the variables
	float amplitude = 1.0f;
	float frequency = 1.0f;
	float speed = 1.0f;
	float time = 0.0f;
	float watertime = 0.0f;
	float random_height = 0.0f;
	float set_height = 1.0f;

	XMFLOAT3 Light_dir_1;
	XMFLOAT3 Light_dir_2;
	XMFLOAT3  Spot_light_dir;

	XMFLOAT3 Spot_light_pos;
	XMFLOAT3 Point_light_pos;

	XMFLOAT3 Light_colour_1;
	XMFLOAT3 Light_colour_2;
	XMFLOAT3 Spot_light_col;
	XMFLOAT3 Point_light_col;

	bool taketime = false;
	bool addtime = false;
	bool post_process_on = false;
};

#endif