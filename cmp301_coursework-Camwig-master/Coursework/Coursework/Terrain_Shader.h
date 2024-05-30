
#pragma once

#include "DXF.h"

#define NUM_LIGHTS 4

using namespace std;
using namespace DirectX;

class Terrain_Shader : public BaseShader
{
private:
	//Sets up the buffers that need to be sent to the shaders

	struct MatrixBufferType
	{
		XMMATRIX world;
		XMMATRIX view;
		XMMATRIX projection;
		XMMATRIX lightView[NUM_LIGHTS];
		XMMATRIX lightProjection[NUM_LIGHTS];
	};

	struct LightBufferType
	{
		XMFLOAT4 ambient;
		XMFLOAT4 diffuse[NUM_LIGHTS];
		XMFLOAT4 position[NUM_LIGHTS];
		XMFLOAT4 direction[NUM_LIGHTS];
		float specularPower;
		XMFLOAT3 padding;
		float height;
		XMFLOAT3 padding2;
	};

	struct CameraBufferType
	{
		XMFLOAT3 cameraPosition;
		float padding;
		float height;
		XMFLOAT3 padding2;
	};

	struct TimeBufferType
	{
		float time;
		XMFLOAT3 padding;
		float amplitude;
		float frequency;
		float speed;
		float padding2;
	};


public:
	Terrain_Shader(ID3D11Device* device, HWND hwnd);
	~Terrain_Shader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& world, const XMMATRIX& view, const XMMATRIX& projection, ID3D11ShaderResourceView* texture, ID3D11ShaderResourceView* texture_2, ID3D11ShaderResourceView* texture_3, ID3D11ShaderResourceView* depthMap1, ID3D11ShaderResourceView* depthMap2, Light* light[NUM_LIGHTS], XMFLOAT3 CameraPosition, Timer* time, float new_amplitude, float new_frequency, float new_speed, float height);

private:
	void initShader(const wchar_t* vs, const wchar_t* ps);

private:
	//Initialises the buffers
	ID3D11Buffer* matrixBuffer;
	ID3D11Buffer* cameraBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11SamplerState* sampleStateShadow;
	ID3D11Buffer* lightBuffer;
	ID3D11Buffer* timeBuffer;

	float running_timer = 0.0f;
};

