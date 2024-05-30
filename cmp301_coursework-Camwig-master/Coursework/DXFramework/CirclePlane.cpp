#include "CirclePlane.h"

// Initialise buffers and lad texture.
CirclePlane::CirclePlane(ID3D11Device* device, ID3D11DeviceContext* deviceContext)
{
	initBuffers(device);

}

// Release resources.
CirclePlane::~CirclePlane()
{
	// Run parent deconstructor
	BaseMesh::~BaseMesh();
}

// Build quad mesh.
void CirclePlane::initBuffers(ID3D11Device* device)
{
	VertexType* vertices;
	unsigned long* indices;
	D3D11_BUFFER_DESC vertexBufferDesc, indexBufferDesc;
	D3D11_SUBRESOURCE_DATA vertexData, indexData;

	vertexCount = 4;
	indexCount = 6;


	vertices = new VertexType[vertexCount];
	indices = new unsigned long[indexCount];

	int n = 10; // number of triangles
	SimpleVertex* vertices = malloc(sizeof(SimpleVertex) * 10 * 3); // 10 triangles, 3 verticies per triangle
	float deltaTheta = 2 * pi / n; // Change in theta for each vertex
	for (int i = 0; i < n; i++) {
		int theta = i * deltaTheta; // Theta is the angle for that triangle
		int index = 3 * i;
		vertices[index + 0] = SimpleVertex::pos(0, 0, 0);
		// Given an angle theta, cosine [cos] will give you the x coordinate,
		// and sine [sin] will give you the y coordinate.
		// #include <math.h>
		vertices[index + 1] = SimpleVertex(cos(theta), sin(theta), 0);
		vertices[index + 2] = SimpleVertex(cos(theta + deltaTheta), sin(theta + deltaTheta), 0);
	}


	// Set up the description of the static vertex buffer.
	vertexBufferDesc.Usage = D3D11_USAGE_DEFAULT;
	vertexBufferDesc.ByteWidth = sizeof(VertexType) * vertexCount;
	vertexBufferDesc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
	vertexBufferDesc.CPUAccessFlags = 0;
	vertexBufferDesc.MiscFlags = 0;
	vertexBufferDesc.StructureByteStride = 0;
	// Give the subresource structure a pointer to the vertex data.
	vertexData.pSysMem = vertices;
	vertexData.SysMemPitch = 0;
	vertexData.SysMemSlicePitch = 0;
	// Now create the vertex buffer.
	device->CreateBuffer(&vertexBufferDesc, &vertexData, &vertexBuffer);

	// Set up the description of the static index buffer.
	indexBufferDesc.Usage = D3D11_USAGE_DEFAULT;
	indexBufferDesc.ByteWidth = sizeof(unsigned long) * indexCount;
	indexBufferDesc.BindFlags = D3D11_BIND_INDEX_BUFFER;
	indexBufferDesc.CPUAccessFlags = 0;
	indexBufferDesc.MiscFlags = 0;
	indexBufferDesc.StructureByteStride = 0;
	// Give the subresource structure a pointer to the index data.
	indexData.pSysMem = indices;
	indexData.SysMemPitch = 0;
	indexData.SysMemSlicePitch = 0;
	// Create the index buffer.
	device->CreateBuffer(&indexBufferDesc, &indexData, &indexBuffer);

	// Release the arrays now that the vertex and index buffers have been created and loaded.
	delete[] vertices;
	vertices = 0;
	delete[] indices;
	indices = 0;
}
