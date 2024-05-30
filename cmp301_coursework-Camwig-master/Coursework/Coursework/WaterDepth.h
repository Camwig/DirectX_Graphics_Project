
#pragma once

#include "DXF.h"

using namespace std;
using namespace DirectX;


class WaterDepth : public BaseShader
{
private:
	struct TimeBufferType
	{
		float time;
		XMFLOAT3 padding;
		float height;
		XMFLOAT3 padding2;
	};

	struct CameraBufferType
	{
		XMFLOAT3 cameraPosition;
		float padding;
	};
public:

	WaterDepth(ID3D11Device* device, HWND hwnd);
	~WaterDepth();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& world, const XMMATRIX& view, const XMMATRIX& projection, ID3D11ShaderResourceView* texture, ID3D11ShaderResourceView* texture2, float timer, float random_height, XMFLOAT3 CameraPosition);

private:
	void initShader(const wchar_t* vs, const wchar_t* ps);

private:
	ID3D11Buffer* matrixBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11Buffer* timeBuffer;
	ID3D11Buffer* cameraBuffer;
};
