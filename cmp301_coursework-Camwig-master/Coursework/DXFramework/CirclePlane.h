// Quad Mesh
// Simple circle mesh, with texture coordinates and normals.
#include <xnamath.h>

#ifndef _CIRCLEPLANE_H_
#define _CIRCLEPLANE_H_

#include "BaseMesh.h"

using namespace DirectX;

struct SimpleVertex
{
	XMFLOAT3 pos;
};

class CirclePlane : public BaseMesh
{

public:
	CirclePlane(ID3D11Device* device, ID3D11DeviceContext* deviceContext);
	~CirclePlane();

protected:
	void initBuffers(ID3D11Device* device);

};

#endif
