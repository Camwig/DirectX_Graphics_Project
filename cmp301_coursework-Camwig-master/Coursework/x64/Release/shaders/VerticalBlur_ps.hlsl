Texture2D shaderTexture : register(t0);
Texture2D depthTexture : register(t1);
SamplerState SampleType : register(s0);

cbuffer ScreenSizeBuffer : register(b0)
{
    float screenHeight;
    float3 padding;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
    float weight1, weight2, weight3, weight4, weight5, weight1_2, weight2_2, weight3_2, weight1_3;
    float4 colour;

	// Create the weights that each neighbor pixel will contribute to the blur.
    weight1 = 0.120849609375;
    weight2 = 0.0537109375;
    weight3 = 0.01611328125;
    weight4 = 0.0029296875;
    weight5 = 0.000244140625;

    // Initialize the colour to black.
    colour = float4(0.0f, 0.0f, 0.0f, 0.0f);

    float texelSize = 1.0f / screenHeight;
    // Add the vertical pixels to the colour by the specific weight of each.
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 5.0f)) * (weight3);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 4.0f)) * (weight2);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 3.0f)) * (weight1);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 2.0f)) * (weight4);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 1.0f)) * (weight5);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -1.0f)) * (weight5);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -2.0f)) * (weight4);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -3.0f)) * (weight3);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -4.0f)) * (weight2);
    colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -5.0f)) * (weight1);
    
    // Set the alpha channel to one.
    colour.a = 1.0f;

    return colour;
}