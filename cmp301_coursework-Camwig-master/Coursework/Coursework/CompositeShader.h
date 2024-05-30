#pragma once

#include "DXF.h"

using namespace std;
using namespace DirectX;

class CompositeShader : public BaseShader
{

public:

	CompositeShader(ID3D11Device* device, HWND hwnd);
	~CompositeShader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& world, const XMMATRIX& view, const XMMATRIX& projection, ID3D11ShaderResourceView* texture, ID3D11ShaderResourceView* texture1, ID3D11ShaderResourceView* depthMap1);

private:
	void initShader(const wchar_t* vs, const wchar_t* ps);

private:
	ID3D11Buffer* matrixBuffer;
	ID3D11SamplerState* sampleState;
};

