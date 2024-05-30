#include "lighting.hlsli"

Texture2D texture0 : register(t0);
Texture2D texture1 : register(t1);
SamplerState sampler0 : register(s0);

cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
};

cbuffer timerBuffer : register(b1)
{
    float time;
    float3 padding;
    float height;
    float3 padding2;
}

cbuffer CameraBuffer : register(b2)
{
    float3 cameraPosition;
    float padding3;
};

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    float3 viewVector : TEXCOORD2;
};

OutputType main(InputType input)
{
    OutputType output;
	
    float4 worldPosition = mul(input.position, worldMatrix);
    output.viewVector = cameraPosition.xyz - worldPosition.xyz;
    output.viewVector = normalize(output.viewVector);
    
    input.position.w = 1.0f;
    
    output.position = input.position;
    
    //Modify the output value by the current height values of the water mesh
    output.position.y += getHeight2(input.tex, texture0,texture1, sampler0,time,height);    
    //Modify the output normals to that of the water mesh
    output.normal = CalcNormal2(input.tex, texture1, texture0, sampler0, time);

	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    // Store the texture coordinates for the pixel shader.
    output.tex = input.tex;
    
    output.worldPosition = mul(input.position, worldMatrix).xyz;

    return output;
}