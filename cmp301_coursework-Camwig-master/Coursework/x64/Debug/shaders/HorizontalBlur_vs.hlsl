cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
};

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};


OutputType main(InputType input)
{
    OutputType output;

    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);

    output.tex = input.tex;

    return output;
}





//#include "lighting.hlsli"

//Texture2D depthMapTexture : register(t0);
//Texture2D shaderTexture : register(t1);
//Texture2D heightTexture : register(t2);

//SamplerState SampleType : register(s0);
//SamplerState DepthSampler : register(s1);


//cbuffer MatrixBuffer : register(b0)
//{
//    matrix worldMatrix;
//    matrix viewMatrix;
//    matrix projectionMatrix;
//};

//struct InputType
//{
//    float4 position : POSITION;
//    float2 tex : TEXCOORD0;
//    float3 normal : NORMAL;
//};

//struct OutputType
//{
//    float4 position : SV_POSITION;
//    float2 tex : TEXCOORD0;
//};


//OutputType main(InputType input)
//{
//    input.normal = (CalcNormal(input.tex.xy, heightTexture, SampleType).x, CalcNormal(input.tex.xy, heightTexture, SampleType).y, CalcNormal(input.tex.xy, heightTexture, SampleType).z, 0.0f);
//    input.position.y = getHeight(input.tex.xy, heightTexture, SampleType);
    
//    OutputType output;

//    output.position = mul(input.position, worldMatrix);
//    output.position = mul(input.position, viewMatrix);
//    output.position = mul(input.position, projectionMatrix);

//    output.tex = input.tex;

//    return output;
//}