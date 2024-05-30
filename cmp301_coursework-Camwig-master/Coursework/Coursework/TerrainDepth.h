#pragma once

#include "DXF.h"

using namespace std;
using namespace DirectX;


class TerrainDepth : public BaseShader
{

private:

	struct CameraBufferType
	{
		XMFLOAT3 cameraPosition;
		float padding;
		float height;
		XMFLOAT3 padding2;
	};

public:

	TerrainDepth(ID3D11Device* device, HWND hwnd);
	~TerrainDepth();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& world, const XMMATRIX& view, const XMMATRIX& projection, ID3D11ShaderResourceView* texture, XMFLOAT3 CameraPosition, float height_);

private:
	void initShader(const wchar_t* vs, const wchar_t* ps);

private:
	ID3D11Buffer* matrixBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11Buffer* cameraBuffer;
};

