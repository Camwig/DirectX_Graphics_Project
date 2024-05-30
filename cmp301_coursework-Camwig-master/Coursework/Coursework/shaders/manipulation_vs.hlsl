// Light vertex shader
// Standard issue vertex shader, apply matrices, pass info to pixel shader
Texture2D texture0 : register(t0);
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
    float amplitude;
    float frequency;
    float speed;
    float padding2;
}

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
};

float getHeight(float2 _uv)
{
    float height = texture0.SampleLevel(sampler0, _uv, 0).x;
    return height * 30.0f;
}

float3 CalcNormal(float2 uv)
{
    float tw = 256.0f;
    float value;
    texture0.GetDimensions(0, tw, tw, value);
    float uvOffset = 1.0f / 100.0f; //sub sampling half the min rate
    float heightN = getHeight(float2(uv.x, uv.y + uvOffset));
    float heightS = getHeight(float2(uv.x, uv.y - uvOffset));
    float heightE = getHeight(float2(uv.x + uvOffset, uv.y));
    float heightW = getHeight(float2(uv.x - uvOffset, uv.y));
	
    float worldstep = uvOffset * 100.0f;
    float3 tangent = normalize(float3(2.0f * worldstep, heightE - heightW, 0.0f));
    float3 bi_tangent = normalize(float3(0.0f, heightN - heightS, 2.0f * worldstep));
    
    return cross(bi_tangent, tangent);
}

OutputType main(InputType input)
{
    OutputType output;
	
    //input.position.x += sine_wave * (texture_uv);
    input.position.w = 1.0f;
    
    output.position = input.position;
    output.position.y += getHeight(input.tex);

	// Calculate the position of the vertex against the world, view, and projection matrices.
    //output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    // Store the texture coordinates for the pixel shader.
    output.tex = input.tex;
	
	// Calculate the normal vector against the world matrix only and normalise.
    output.normal = mul(CalcNormal(input.tex), (float3x3) worldMatrix);
    output.normal = normalize(output.normal);

    return output;
}