#include "App1.h"

App1::App1()
{
	terrain_mesh = nullptr;
	shader = nullptr;
}

void App1::init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN)
{
	// Call super/parent init function (required!)
	BaseApplication::init(hinstance, hwnd, screenWidth, screenHeight, in, VSYNC, FULL_SCREEN);

	//Sets default setup values for the scene
	post_process_on = false;

	Light_dir_1 = XMFLOAT3(-0.435,-0.350,0.295);
	Light_dir_2 = XMFLOAT3(0.650, -0.288, -0.285);
	Spot_light_dir = XMFLOAT3(0.0, -0.7, 0.7);

	Spot_light_pos = XMFLOAT3(73, 89, 77);
	Point_light_pos = XMFLOAT3(141.250, -8.0, 27.0);

	Light_colour_1 = XMFLOAT3(0, 1, 0);
	Light_colour_2 = XMFLOAT3(0.78f, 0, 0);
	Spot_light_col = XMFLOAT3(0.2, 0.2, 0.2);
	Point_light_col = XMFLOAT3(0.575, 0, 0.8);

	set_height = 30.0f;

	// Load texture.
	textureMgr->loadTexture(L"alex", L"res/ALEX_2.png");
	textureMgr->loadTexture(L"gem", L"res/fire gem.png");
	textureMgr->loadTexture(L"Wood", L"res/wood2.png");
	textureMgr->loadTexture(L"height", L"res/height.png");
	textureMgr->loadTexture(L"waterheight", L"res/heightmap-water.png");
	textureMgr->loadTexture(L"waterheight2", L"res/heightmap-water 2.png");
	textureMgr->loadTexture(L"grass", L"res/Grass.png");
	textureMgr->loadTexture(L"sand", L"res/beach_sand.png");
	textureMgr->loadTexture(L"water", L"res/tex_Water.png");

	// Create Mesh object and shader object
	orthoMesh = new OrthoMesh(renderer->getDevice(), renderer->getDeviceContext(), screenWidth, screenHeight);	// Full screen size/*new OrthoMesh(renderer->getDevice(), renderer->getDeviceContext(), screenWidth / 4, screenHeight / 4, -screenWidth / 2.7, screenHeight / 2.7);*/
	orthoMesh2 = new OrthoMesh(renderer->getDevice(), renderer->getDeviceContext(), screenWidth / 4, screenHeight / 4, -screenWidth / 2.7, screenHeight / 2.7);
	terrain_mesh = new PlaneMesh(renderer->getDevice(), renderer->getDeviceContext());
	flat_mesh = new PlaneMesh(renderer->getDevice(), renderer->getDeviceContext());
	water_mesh = new PlaneMesh(renderer->getDevice(), renderer->getDeviceContext());
	tess_mesh = new TessellationMesh(renderer->getDevice(), renderer->getDeviceContext());

	quad = new QuadMesh(renderer->getDevice(), renderer->getDeviceContext());

	Alex_model = new AModel(renderer->getDevice(), "res/Alex.obj");
	for (int i = 0; i < 2; i++)
	{
		Fire_gem_model[i] = new AModel(renderer->getDevice(), "res/Fire Gem.obj");
	}

	sampleMesh = new OrthoMesh(renderer->getDevice(), renderer->getDeviceContext(), screenWidth, screenHeight);
	UpMesh = new OrthoMesh(renderer->getDevice(), renderer->getDeviceContext(), screenWidth, screenHeight);

	//Setup the shaders
	shader = new ManipulationShader(renderer->getDevice(), hwnd);
	tessShader = new TesselationShader(renderer->getDevice(), hwnd);
	this_shader = new Terrain_Shader(renderer->getDevice(), hwnd);
	watershader = new Water_Shader(renderer->getDevice(), hwnd);
	horizontal_blur = new HorizontalBlurShader(renderer->getDevice(), hwnd);
	vertical_blur = new VerticalBlurShader(renderer->getDevice(), hwnd);
	composite_pass = new CompositeShader(renderer->getDevice(), hwnd);
	depthShader = new DepthShader(renderer->getDevice(), hwnd);
	terrain_d = new TerrainDepth(renderer->getDevice(), hwnd);
	water_d = new WaterDepth(renderer->getDevice(), hwnd);
	shadowShader = new ShadowShader(renderer->getDevice(), hwnd);
	textureShader = new TextureShader(renderer->getDevice(), hwnd);

	// Variables for defining shadow map
	int shadowmapWidth = 1024*8;
	int shadowmapHeight = 1024*8;
	int sceneWidth = 100;
	int sceneHeight = 100;

	//Setup the shadowmaps and depthmap
	shadowMap[0] = new ShadowMap(renderer->getDevice(), shadowmapWidth, shadowmapHeight);
	shadowMap[1] = new ShadowMap(renderer->getDevice(), shadowmapWidth, shadowmapHeight);
	depthmap = new ShadowMap(renderer->getDevice(), shadowmapWidth, shadowmapHeight);

	//Setup the rendertextures
	renderTexture = new RenderTexture(renderer->getDevice(), screenWidth, screenHeight, SCREEN_NEAR, SCREEN_DEPTH);
	horizontalBlurTexture = new RenderTexture(renderer->getDevice(), screenWidth, screenHeight, SCREEN_NEAR, SCREEN_DEPTH);
	verticalBlurTexture = new RenderTexture(renderer->getDevice(), screenWidth, screenHeight, SCREEN_NEAR, SCREEN_DEPTH);
	compositeTexture = new RenderTexture(renderer->getDevice(), screenWidth, screenHeight, SCREEN_NEAR, SCREEN_DEPTH);

	//Directional light 1
	light[0] = new Light();
	light[0]->setAmbientColour(0.3f, 0.3f, 0.3f, 1.0f);
	light[0]->setDiffuseColour(Light_colour_1.x, Light_colour_1.y, Light_colour_1.z, 0.0f);
	light[0]->setDirection(0.0f, -0.7f, 0.7f);
	light[0]->setPosition(0.f, 0.f, -10.f);
	light[0]->generateOrthoMatrix(200.0f, 200.0f, 0.1f, 200.f);

	//Directional light 2
	light[1] = new Light();
	light[1]->setAmbientColour(0.3f, 0.3f, 0.3f, 1.0f);
	light[1]->setDiffuseColour(Light_colour_2.x, Light_colour_2.y, Light_colour_2.z, 0.0f);
	light[1]->setDirection(Light_dir_2.x, Light_dir_2.y, Light_dir_2.z);
	light[1]->setPosition(0.f, 0.f, -500.f);
	light[1]->generateOrthoMatrix(200.0f, 200.0f, 0.1f, 200.f);

	//Spotlight
	light[2] = new Light();
	light[2]->setDirection(Spot_light_dir.x, Spot_light_dir.y, Spot_light_dir.z);
	light[2]->setDiffuseColour(Spot_light_col.x, Spot_light_col.y, Spot_light_col.z, 0.0f);
	light[2]->setPosition(Spot_light_pos.x, Spot_light_pos.y, Spot_light_pos.z);
	light[2]->setPosition(100.0f, 10.0f, 5.0f);

	//Pointlight
	light[3] = new Light();
	light[3]->setDiffuseColour(Point_light_col.x, Point_light_col.y, Point_light_col.z, 0.0f);
	light[3]->setPosition(Point_light_pos.x, Point_light_pos.y, Point_light_pos.z);

}


App1::~App1()
{
	// Run base application deconstructor
	BaseApplication::~BaseApplication();

	// Release the Direct3D object.
	if (terrain_mesh)
	{
		delete terrain_mesh;
		terrain_mesh = 0;
	}

	if (shader)
	{
		delete shader;
		shader = 0;
	}
}


bool App1::frame()
{
	bool result;
	
	//Updates the direction,colour and positions depending on the new version of the values
	light[0]->setDirection(Light_dir_2.x, Light_dir_2.y, Light_dir_2.z);
	light[1]->setDirection(Light_dir_1.x, Light_dir_1.y, Light_dir_1.z);
	light[2]->setDirection(Spot_light_dir.x, Spot_light_dir.y, Spot_light_dir.z);

	light[2]->setPosition(Spot_light_pos.x, Spot_light_pos.y, Spot_light_pos.z);
	light[3]->setPosition(Point_light_pos.x, Point_light_pos.y, Point_light_pos.z);

	light[0]->setDiffuseColour(Light_colour_1.x, Light_colour_1.y, Light_colour_1.z, 0.0f);
	light[1]->setDiffuseColour(Light_colour_2.x, Light_colour_2.y, Light_colour_2.z, 0.0f);
	light[2]->setDiffuseColour(Spot_light_col.x, Spot_light_col.y, Spot_light_col.z, 0.0f);
	light[3]->setDiffuseColour(Point_light_col.x, Point_light_col.y, Point_light_col.z, 0.0f);

	result = BaseApplication::frame();
	if (!result)
	{
		return false;
	}

	// Render the graphics.
	result = render();
	if (!result)
	{
		return false;
	}

	return true;
}

bool App1::render()
{
	//Checks if the post process should be done and runs the appopriate function
	if (post_process_on)
	{
		depthPass();
		firstPass();
		HorizontalPass();
		VerticalPass();
		CompositePass();
		finalPass();
	}
	else
	{
		depthPass();
		BasePass();
	}
	return true;
}

void App1::depthPass()
{
	XMMATRIX worldMatrix = renderer->getWorldMatrix();
	XMMATRIX lightProjectionMatrix;
	XMMATRIX lightViewMatrix;
	for (int i = 0; i < 2; i++)
	{
		shadowMap[i]->BindDsvAndSetNullRenderTarget(renderer->getDeviceContext());

		light[i]->generateViewMatrix();
		lightViewMatrix = light[i]->getViewMatrix();
		lightProjectionMatrix = light[i]->getOrthoMatrix();

		XMFLOAT3 lightOffset = light[i]->getDirection();
		lightOffset = XMFLOAT3(-lightOffset.x * 71, -lightOffset.y * 71, -lightOffset.z * 71);
		light[i]->setPosition(lightOffset.x + 50.0f, lightOffset.y, lightOffset.z + 50.0f);

		worldMatrix = renderer->getWorldMatrix();
		XMMATRIX scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);

		//Render Terrain for shadow maps
		terrain_mesh->sendData(renderer->getDeviceContext());
		terrain_d->setShaderParameters(renderer->getDeviceContext(), worldMatrix, lightViewMatrix, lightProjectionMatrix ,textureMgr->getTexture(L"height"),camera->getPosition(),set_height);
		terrain_d->render(renderer->getDeviceContext(), terrain_mesh->getIndexCount());

		//Render models for shadow maps
		worldMatrix = renderer->getWorldMatrix();
		worldMatrix = XMMatrixTranslation(10.f, 0.25, 2.5f);
		scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
		worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

		Alex_model->sendData(renderer->getDeviceContext());
		depthShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, lightViewMatrix, lightProjectionMatrix);
		depthShader->render(renderer->getDeviceContext(), Alex_model->getIndexCount());

		worldMatrix = renderer->getWorldMatrix();
		worldMatrix = XMMatrixTranslation(7.5f, 1.25f, 2.5f);
		scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
		worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

		Fire_gem_model[0]->sendData(renderer->getDeviceContext());
		depthShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, lightViewMatrix, lightProjectionMatrix);
		depthShader->render(renderer->getDeviceContext(), Fire_gem_model[0]->getIndexCount());

		worldMatrix = renderer->getWorldMatrix();
		worldMatrix = XMMatrixTranslation(12.5, 1.25f, 2.5f);
		scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
		worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

		Fire_gem_model[1]->sendData(renderer->getDeviceContext());
		depthShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, lightViewMatrix, lightProjectionMatrix);
		depthShader->render(renderer->getDeviceContext(), Fire_gem_model[1]->getIndexCount());
	}
	renderer->setBackBufferRenderTarget();
	renderer->resetViewport();

	camera->update();

	//Runs a very minimal delta time variable
	//That is clamped between 1 and 0
	if (watertime <= 0.0f)
	{
		addtime = true;
		taketime = false;
	}

	if (watertime > 1.0f)
	{
		taketime = true;
		addtime = false;
	}

	if (taketime == true)
	{
		watertime -= time;
	}

	if (addtime == true)
	{
		watertime += time;
	}

	std::srand(timer->getTime());

	random_height = rand() % 30 + 1;

	//Depth of field depth shader

	worldMatrix = renderer->getWorldMatrix();
	XMMATRIX viewMatrix = camera->getViewMatrix();
	XMMATRIX projectionMatrix = renderer->getProjectionMatrix();

	depthmap->BindDsvAndSetNullRenderTarget(renderer->getDeviceContext());

	terrain_mesh->sendData(renderer->getDeviceContext());
	terrain_d->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"height"), camera->getPosition(), random_height);
	terrain_d->render(renderer->getDeviceContext(), terrain_mesh->getIndexCount());

	worldMatrix = XMMatrixTranslation(120.f, 2.f, 0.f);
	XMMATRIX scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	water_mesh->sendData(renderer->getDeviceContext());
	water_d->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"waterheight"), textureMgr->getTexture(L"waterheight2"), watertime, random_height, camera->getPosition());
	watershader->render(renderer->getDeviceContext(), water_mesh->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(10.f, 0.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	Alex_model->sendData(renderer->getDeviceContext());
	depthShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix);
	depthShader->render(renderer->getDeviceContext(), Alex_model->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(7.5f, 1.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);
	Fire_gem_model[0]->sendData(renderer->getDeviceContext());
	depthShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix);
	depthShader->render(renderer->getDeviceContext(), Alex_model->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(12.5, 1.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);
	Fire_gem_model[1]->sendData(renderer->getDeviceContext());
	depthShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix);
	depthShader->render(renderer->getDeviceContext(), Alex_model->getIndexCount());

	time = timer->getTime();

	renderer->setBackBufferRenderTarget();
	renderer->resetViewport();
}

void App1::firstPass()
{
	// Set the render target to be the render to texture and clear it
	renderTexture->setRenderTarget(renderer->getDeviceContext());
	renderTexture->clearRenderTarget(renderer->getDeviceContext(), 0.39f, 0.58f, 0.92f, 1.0f);

	XMMATRIX worldMatrix, viewMatrix, projectionMatrix;

	// Generate the view matrix based on the camera's position.
	camera->update();

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	viewMatrix = camera->getViewMatrix();
	projectionMatrix = renderer->getProjectionMatrix();

	terrain_mesh->sendData(renderer->getDeviceContext());
	this_shader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"height"), textureMgr->getTexture(L"grass"), textureMgr->getTexture(L"sand"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition(), timer, amplitude, frequency, speed, set_height);
	this_shader->render(renderer->getDeviceContext(), terrain_mesh->getIndexCount());

	worldMatrix = XMMatrixTranslation(120.f, 2.f, 0.f);
	XMMATRIX scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	water_mesh->sendData(renderer->getDeviceContext());
	watershader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"water"), textureMgr->getTexture(L"waterheight"), textureMgr->getTexture(L"waterheight2"), light, camera->getPosition(), watertime, random_height);
	watershader->render(renderer->getDeviceContext(), water_mesh->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(10.f, 0.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);
	Alex_model->sendData(renderer->getDeviceContext());
	shadowShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"alex"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition());
	shadowShader->render(renderer->getDeviceContext(), Alex_model->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(7.5f, 1.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);
	Fire_gem_model[0]->sendData(renderer->getDeviceContext());
	shadowShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"gem"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition());
	shadowShader->render(renderer->getDeviceContext(), Fire_gem_model[0]->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(12.5, 1.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);
	Fire_gem_model[1]->sendData(renderer->getDeviceContext());
	shadowShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"gem"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition());
	shadowShader->render(renderer->getDeviceContext(), Fire_gem_model[1]->getIndexCount());

	renderer->setBackBufferRenderTarget();
}


void App1::BasePass()
{
	XMMATRIX worldMatrix, viewMatrix, projectionMatrix;

	// Clear the scene. (default blue colour)
	renderer->beginScene(0.39f, 0.58f, 0.92f, 1.0f);

	// Generate the view matrix based on the camera's position.
	camera->update();

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	viewMatrix = camera->getViewMatrix();
	projectionMatrix = renderer->getProjectionMatrix();

	terrain_mesh->sendData(renderer->getDeviceContext());
	this_shader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"height"), textureMgr->getTexture(L"grass"), textureMgr->getTexture(L"sand"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition(), timer, amplitude, frequency, speed, set_height);
	this_shader->render(renderer->getDeviceContext(), terrain_mesh->getIndexCount());

	worldMatrix = XMMatrixTranslation(120.f, 2.f, 0.f);
	XMMATRIX scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	water_mesh->sendData(renderer->getDeviceContext());
	watershader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"water"), textureMgr->getTexture(L"waterheight"), textureMgr->getTexture(L"waterheight2"), light, camera->getPosition(), watertime, random_height);
	watershader->render(renderer->getDeviceContext(), water_mesh->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(10.f, 0.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	Alex_model->sendData(renderer->getDeviceContext());
	shadowShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"alex"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition());
	shadowShader->render(renderer->getDeviceContext(), Alex_model->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(7.5f, 1.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	Fire_gem_model[0]->sendData(renderer->getDeviceContext());
	shadowShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"gem"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition());
	shadowShader->render(renderer->getDeviceContext(), Fire_gem_model[0]->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(12.5, 1.25, 2.5f);
	scaleMatrix = XMMatrixScaling(2.5f, 2.5f, 2.5f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	Fire_gem_model[1]->sendData(renderer->getDeviceContext());
	shadowShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"gem"), shadowMap[0]->getDepthMapSRV(), shadowMap[1]->getDepthMapSRV(), light, camera->getPosition());
	shadowShader->render(renderer->getDeviceContext(), Fire_gem_model[1]->getIndexCount());

	worldMatrix = renderer->getWorldMatrix();
	scaleMatrix = XMMatrixScaling(1.0f, 1.0f, 1.0f);

	worldMatrix = renderer->getWorldMatrix();
	worldMatrix = XMMatrixTranslation(-2.0f, 1, 1.f);
	scaleMatrix = XMMatrixScaling(5.f, 5.f, 5.f);
	worldMatrix = XMMatrixMultiply(worldMatrix, scaleMatrix);

	tess_mesh->sendData(renderer->getDeviceContext());
	tessShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"Wood"), XMFLOAT4(1, 1, 1, 1), XMFLOAT2(1, 1), camera->getPosition());
	tessShader->render(renderer->getDeviceContext(), tess_mesh->getIndexCount());

	// Render GUI
	gui();

	// Swap the buffers
	renderer->endScene();
}

void App1::HorizontalPass()
{
	XMMATRIX worldMatrix, baseViewMatrix, orthoMatrix;

	//Set the screen size along the x-axis and the horizontal blur texture
	float screenSizeX = (float)horizontalBlurTexture->getTextureWidth();
	horizontalBlurTexture->setRenderTarget(renderer->getDeviceContext());
	horizontalBlurTexture->clearRenderTarget(renderer->getDeviceContext(), 0.39f, 0.58f, 0.92f, 1.0f);

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	baseViewMatrix = camera->getOrthoViewMatrix();
	orthoMatrix = horizontalBlurTexture->getOrthoMatrix();

	// Render for Horizontal Blur
	renderer->setZBuffer(false);

	//Horizontal Blur texture
	orthoMesh->sendData(renderer->getDeviceContext());
	horizontal_blur->setShaderParameters(renderer->getDeviceContext(), worldMatrix, baseViewMatrix, orthoMatrix, renderTexture->getShaderResourceView(), depthmap->getDepthMapSRV(), screenSizeX);
	horizontal_blur->render(renderer->getDeviceContext(), orthoMesh->getIndexCount());

	renderer->setZBuffer(true);

	// Reset the render target back to the original back buffer and not the render to texture anymore.
	renderer->setBackBufferRenderTarget();
}

void App1::VerticalPass()
{
	XMMATRIX worldMatrix, baseViewMatrix, orthoMatrix;

	//Set the screen size along the y-axis and the vertical blur texture
	float screenSizeY = (float)verticalBlurTexture->getTextureHeight();
	verticalBlurTexture->setRenderTarget(renderer->getDeviceContext());
	verticalBlurTexture->clearRenderTarget(renderer->getDeviceContext(), 0.39f, 0.58f, 0.92f, 1.0f);

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	baseViewMatrix = camera->getOrthoViewMatrix();
	orthoMatrix = verticalBlurTexture->getOrthoMatrix();

	// Render for Vertical Blur
	renderer->setZBuffer(false);

	//Vertical blur texture
	orthoMesh->sendData(renderer->getDeviceContext());
	vertical_blur->setShaderParameters(renderer->getDeviceContext(), worldMatrix, baseViewMatrix, orthoMatrix, horizontalBlurTexture->getShaderResourceView(), depthmap->getDepthMapSRV(), screenSizeY);
	vertical_blur->render(renderer->getDeviceContext(), orthoMesh->getIndexCount());

	renderer->setZBuffer(true);

	// Reset the render target back to the original back buffer and not the render to texture anymore.
	renderer->setBackBufferRenderTarget();
}

void App1::CompositePass()
{
	XMMATRIX worldMatrix, baseViewMatrix, orthoMatrix;

	//Sets the composite texture
	compositeTexture->setRenderTarget(renderer->getDeviceContext());
	compositeTexture->clearRenderTarget(renderer->getDeviceContext(), 0.39f, 0.58f, 0.92f, 1.0f);

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	baseViewMatrix = camera->getOrthoViewMatrix();
	orthoMatrix = horizontalBlurTexture->getOrthoMatrix();

	// Render for composite texture
	renderer->setZBuffer(false);

	//Composite texture
	orthoMesh->sendData(renderer->getDeviceContext());
	composite_pass->setShaderParameters(renderer->getDeviceContext(), worldMatrix, baseViewMatrix, orthoMatrix, renderTexture->getShaderResourceView(), verticalBlurTexture->getShaderResourceView(), depthmap->getDepthMapSRV());
	composite_pass->render(renderer->getDeviceContext(), orthoMesh->getIndexCount());

	renderer->setZBuffer(true);

	// Reset the render target back to the original back buffer and not the render to texture anymore.
	renderer->setBackBufferRenderTarget();
}

void App1::finalPass()
{
	// Clear the scene. (default blue colour)
	renderer->beginScene(0.39f, 0.58f, 0.92f, 1.0f);

	// RENDER THE RENDER TEXTURE SCENE
	// Requires 2D rendering and an ortho mesh.
	renderer->setZBuffer(false);
	XMMATRIX worldMatrix = renderer->getWorldMatrix();
	XMMATRIX orthoMatrix = renderer->getOrthoMatrix();  // ortho matrix for 2D rendering
	XMMATRIX orthoViewMatrix = camera->getOrthoViewMatrix();	// Default camera position for orthographic rendering

	orthoMesh->sendData(renderer->getDeviceContext());
	textureShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, orthoViewMatrix, orthoMatrix, compositeTexture->getShaderResourceView());
	textureShader->render(renderer->getDeviceContext(), orthoMesh->getIndexCount());
	renderer->setZBuffer(true);

	renderer->setZBuffer(false);

	orthoMesh2->sendData(renderer->getDeviceContext());
	textureShader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, orthoViewMatrix, orthoMatrix, renderTexture->getShaderResourceView());
	textureShader->render(renderer->getDeviceContext(), orthoMesh2->getIndexCount());

	renderer->setZBuffer(true);
	renderer->setBackBufferRenderTarget();

	time = timer->getTime();

	// Render GUI
	gui();

	// Present the rendered scene to the screen.
	renderer->endScene();
}

void App1::gui()
{
	renderer->getDeviceContext()->GSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->HSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->DSSetShader(NULL, NULL, 0);

	// Force turn off unnecessary shader stages.
	renderer->getDeviceContext()->GSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->HSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->DSSetShader(NULL, NULL, 0);

	// Build UI
	ImGui::Text("FPS: %.2f", timer->getFPS());

	ImGui::Checkbox("Post-Process Depth of field ON/OFF mode", &post_process_on);

	ImGui::Checkbox("Wireframe mode", &wireframeToggle);

	if (ImGui::CollapsingHeader("Directional light 1"))
	{
		ImGui::SliderFloat("Direction X", &Light_dir_1.x, -1, 1);
		ImGui::SliderFloat("Direction Y", &Light_dir_1.y, -1, 0);
		ImGui::SliderFloat("Direction Z", &Light_dir_1.z, -1, 1);

		ImGui::SliderFloat("Directional 1 Colour-R", &Light_colour_1.x, 0, 1);
		ImGui::SliderFloat("Directional 1 Colour-G", &Light_colour_1.y, 0, 1);
		ImGui::SliderFloat("Directional 1 Colour-B", &Light_colour_1.z, 0, 1);
	}

	if (Light_dir_1.x == 0.0f && Light_dir_1.y == 0.0f && Light_dir_1.z == 0.0f)
	{
		Light_dir_1.x = 0.001;
	}

	if (ImGui::CollapsingHeader("Directional light 2"))
	{
		ImGui::SliderFloat("Direction X2", &Light_dir_2.x, -1, 1);
		ImGui::SliderFloat("Direction Y2", &Light_dir_2.y, -1, 0);
		ImGui::SliderFloat("Direction Z2", &Light_dir_2.z, -1, 1);

		ImGui::SliderFloat("Directional 2 Colour-R", &Light_colour_2.x, 0, 1);
		ImGui::SliderFloat("Directional 2 Colour-G", &Light_colour_2.y, 0, 1);
		ImGui::SliderFloat("Directional 2 Colour-B", &Light_colour_2.z, 0, 1);
	}

	if (Light_dir_2.x == 0.0f && Light_dir_2.y == 0.0f && Light_dir_2.z == 0.0f)
	{
		Light_dir_2.x = 0.001;
	}

	if (ImGui::CollapsingHeader("Spotlight"))
	{
		ImGui::SliderFloat("Spotlight Position X", &Spot_light_pos.x, -100, 100);
		ImGui::SliderFloat("Spotlight Position Y", &Spot_light_pos.y, -100, 100);
		ImGui::SliderFloat("Spotlight Position Z", &Spot_light_pos.z, -100, 100);

		ImGui::SliderFloat("Spotlight Colour-R", &Spot_light_col.x, 0, 1);
		ImGui::SliderFloat("Spotlight Colour-G", &Spot_light_col.y, 0, 1);
		ImGui::SliderFloat("Spotlight Colour-B", &Spot_light_col.z, 0, 1);

		ImGui::SliderFloat("Spotlight Direction X", &Spot_light_dir.x, -1, 1);
		ImGui::SliderFloat("Spotlight Direction Y", &Spot_light_dir.y, -1, 0);
		ImGui::SliderFloat("Spotlight Direction Z", &Spot_light_dir.z, -1, 1);
	}

	if (Spot_light_dir.x == 0.0f && Spot_light_dir.y == 0.0f && Spot_light_dir.z == 0.0f)
	{
		Spot_light_dir.x = 0.001;
	}

	if (ImGui::CollapsingHeader("PointLight"))
	{
		ImGui::SliderFloat("Pointlight Position X", &Point_light_pos.x, 100, 200);
		ImGui::SliderFloat("Pointlight Position Y", &Point_light_pos.y, -100, 100);
		ImGui::SliderFloat("Pointlight Position Z", &Point_light_pos.z, -100, 100);

		ImGui::SliderFloat("Pointlight Colour-R", &Point_light_col.x, 0, 1);
		ImGui::SliderFloat("Pointlight Colour-G", &Point_light_col.y, 0, 1);
		ImGui::SliderFloat("Pointlight Colour-B", &Point_light_col.z, 0, 1);
	}

	ImGui::SliderFloat("Height", &set_height, 1, 50);

	// Render UI
	ImGui::Render();
	ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
}
