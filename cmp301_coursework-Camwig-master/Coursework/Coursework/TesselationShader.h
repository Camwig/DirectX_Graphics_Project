#pragma once

#include "BaseShader.h"

using namespace std;
using namespace DirectX;

class TesselationShader : public BaseShader
{
private:
	struct TesselationBufferType
	{
		XMFLOAT4 Outside_Tesselation;
		XMFLOAT2 Inside_Tesselation;
		XMFLOAT2 padding;
		XMFLOAT3 cam_pos;
		float padding2;
	};

public:
	TesselationShader(ID3D11Device* device, HWND hwnd);
	~TesselationShader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& world, const XMMATRIX& view, const XMMATRIX& projection, ID3D11ShaderResourceView* texture, XMFLOAT4 Outside, XMFLOAT2 Inside, XMFLOAT3 camPos);

private:
	void initShader(const wchar_t* vs, const wchar_t* ps);
	void initShader(const wchar_t* vsFilename, const wchar_t* hsFilename, const wchar_t* dsFilename, const wchar_t* psFilename);
private:
	ID3D11Buffer* matrixBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11Buffer* tessellationBuffer;
};