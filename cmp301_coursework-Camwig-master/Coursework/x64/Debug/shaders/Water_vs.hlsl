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
    
    //input.position.y = (amplitude * sin((2 * 3.14159 / frequency) * (input.position.x + time * speed))) * (input.normal);
	
    //input.position.y += amplitude * sin((2 * 3.14159 / frequency) * (input.position.z + time * speed));
	
    //float3 sine_wave = (amplitude * sin((2 * 3.14159 / frequency) * (input.position.x + time * speed)));
    //float3 sine_wave = (amplitude * sin((input.position.x + time * speed) * frequency));
	
    //input.position.y = sine_wave;
    float4 worldPosition = mul(input.position, worldMatrix);
    output.viewVector = cameraPosition.xyz - worldPosition.xyz;
    output.viewVector = normalize(output.viewVector);
    
    input.position.w = 1.0f;
    
    output.position = input.position;
    
    output.position.y += getHeight2(input.tex, texture0,texture1, sampler0,time,height);    
    output.normal = CalcNormal2(input.tex, texture1, texture0, sampler0, time);
	////modify normals
    //output.normal = float3(amplitude * -cos((input.position.x + time * speed) * frequency), 1, 0);
    //output.normal = normalize(output.normal);
    //output.normal = float3(amplitude * cos((2 * 3.14159 / frequency) * (input.position.x + time * speed)), 1, 0);
    //output.normal += float3(amplitude * -sin((2 * 3.14159 / frequency) * (input.position.z + time * speed)), 1, 0);
    
    //float4 worldPosition = mul(input.position, worldMatrix);
    //output.viewVector = cameraPosition.xyz - worldPosition.xyz;
    //output.viewVector = normalize(output.viewVector);

	// Calculate the position of the vertex against the world, view, and projection matrices.
    //output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    // Store the texture coordinates for the pixel shader.
    output.tex = input.tex;
    
    output.worldPosition = mul(input.position, worldMatrix).xyz;

    return output;
}