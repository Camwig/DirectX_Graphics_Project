
#pragma once

#include "DXF.h"

#define NUM_LIGHTS 4

using namespace std;
using namespace DirectX;

class Water_Shader : public BaseShader
{
private:
	//Setup the data buffers that will be sent to the appropriate shader

	struct LightBufferType
	{
		XMFLOAT4 ambient;
		XMFLOAT4 diffuse[NUM_LIGHTS];
		XMFLOAT4 position[NUM_LIGHTS];
		XMFLOAT4 direction[NUM_LIGHTS];
		float specularPower;
		XMFLOAT3 padding;
	};

	struct CameraBufferType
	{
		XMFLOAT3 cameraPosition;
		float padding;
	};

	struct TimeBufferType
	{
		float time;
		XMFLOAT3 padding;
		float height;
		XMFLOAT3 padding2;
	};

public:
	Water_Shader(ID3D11Device* device, HWND hwnd);
	~Water_Shader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& worldMatrix, const XMMATRIX& viewMatrix, const XMMATRIX& projectionMatrix, ID3D11ShaderResourceView* texture, ID3D11ShaderResourceView* texture2, ID3D11ShaderResourceView* texture3, Light* light[NUM_LIGHTS], XMFLOAT3 CameraPosition, float timer, float random_height);

private:
	void initShader(const wchar_t* cs, const wchar_t* ps);

private:
	//Initialies the buffers
	ID3D11Buffer* matrixBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11Buffer* cameraBuffer;
	ID3D11Buffer* lightBuffer;
	ID3D11Buffer* timeBuffer;

	float running_timer = 0.0f;
};

