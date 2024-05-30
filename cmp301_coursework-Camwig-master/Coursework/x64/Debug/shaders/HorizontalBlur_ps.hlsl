Texture2D shaderTexture : register(t0);
SamplerState SampleType : register(s0);

cbuffer ScreenSizeBuffer : register(b0)
{
    float screenWidth;
    float3 padding;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
    float weight0, weight1, weight2, weight3, weight4;
    float4 colour;

	// Create the weights that each neighbor pixel will contribute to the blur.
    weight0 = 0.382928 * 5;
    weight1 = 0.241732 * 5;
    weight2 = 0.060598 * 5;
    weight3 = 0.005977 * 5;
    weight4 = 0.000229 * 5;

	// Initialize the colour to black.
    colour = float4(0.0f, 0.0f, 0.0f, 0.0f);

    float texelSize = 1.0f / screenWidth;
    // Add the horizontal pixels to the colour by the specific weight of each.
    colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * -2.0f, 0.0f)) * weight2;
    colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * -1.0f, 0.0f)) * weight1;
    colour += shaderTexture.Sample(SampleType, input.tex) * weight0;
    colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * 1.0f, 0.0f)) * weight1;
    colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * 2.0f, 0.0f)) * weight2;

	// Set the alpha channel to one.
    colour.a = 1.0f;

    return colour;
}

//#include "lighting.hlsli"

//Texture2D depthMapTexture : register(t0);
//Texture2D shaderTexture : register(t1);
//Texture2D heightTexture : register(t2);

//SamplerState SampleType : register(s0);
//SamplerState DepthSampler : register(s1);


//cbuffer ScreenSizeBuffer : register(b0)
//{
//    float screenWidth;
//    float direction;
//    float3 camPos;
//    float3 padding;
//};

//struct InputType
//{
//    float4 position : POSITION;
//    float4 tex : TEXCOORD0;
//    float3 normal : NORMAL;
//    float4 camViewpos : TEXCOORD1;
//};

//struct OutputType
//{
//    float4 position : SV_POSITION;
//    float2 tex : TEXCOORD0;
//    float3 normal : NORMAL;
//};

//float getDepth(Texture2D sMap, float2 uv)
//{
//    // Sample the shadow map (get depth of geometry)
//    float depthValue = sMap.Sample(DepthSampler, uv).r;
//    return depthValue;
//}

//float2 getProjectiveCoords(float4 camViewpos)
//{
//    // Calculate the projected texture coordinates.
//    float2 projTex = camViewpos.xy / camViewpos.w;
//    projTex *= float2(0.5, -0.5);
//    projTex += float2(0.5f, 0.5f);
//    return projTex;
//}

//float4 main(InputType input) : SV_TARGET
//{
//    input.normal = CalcNormal(input.tex.xy, heightTexture, SampleType);
//    input.position.y += getHeight(input.tex.xy, heightTexture, SampleType);
    
//    float weight0, weight1, weight2, weight3, weight4;
//    float4 colour;
//    colour = shaderTexture.Sample(SampleType, input.tex.xy);
    
//    float2 pTexCoord = getProjectiveCoords(input.camViewpos);
    
//    float depth = (getDepth(depthMapTexture, (pTexCoord)));
    
//    if (direction == 0.0f)
//    {
    
//	    // Create the weights that each neighbor pixel will contribute to the blur.
//        weight0 = 0.382928 * 5;
//        weight1 = 0.241732 * 5;
//        weight2 = 0.060598 * 5;
//        weight3 = 0.005977 * 5;
//        weight4 = 0.000229 * 5;
//        // Initialize the colour to black.
//       // float4 textureColor = texture0.Sample(Sampler0, input.tex);
    
//        if (depth < 0.9f)
//        {

//            float texelSize = 1.0f / screenWidth;
//            // Add the horizontal pixels to the colour by the specific weight of each.
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * -2.0f, 0.0f)) * weight2;
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * -1.0f, 0.0f)) * weight1;
//            colour += shaderTexture.Sample(SampleType, input.tex) * weight0;
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * 1.0f, 0.0f)) * weight1;
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(texelSize * 2.0f, 0.0f)) * weight2;

//	        // Set the alpha channel to one.
//            colour.a = 1.0f;
//            //colour = (0, 0, 0, 0);
        
//        }
//    }
//    else if (direction == 1.0f)
//    {
//        // Create the weights that each neighbor pixel will contribute to the blur.
//        weight0 = 0.382928 * 5;
//        weight1 = 0.241732 * 5;
//        weight2 = 0.060598 * 5;
//        weight3 = 0.005977 * 5;
//        weight4 = 0.000229 * 5;
    
//        if (depth < 0.9f)
//        {

//            float texelSize = 1.0f / screenWidth;
//            // Add the horizontal pixels to the colour by the specific weight of each.
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -2.0f)) * weight2;
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * -1.0f)) * weight1;
//            colour += shaderTexture.Sample(SampleType, input.tex) * weight0;
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 1.0f)) * weight1;
//            colour += shaderTexture.Sample(SampleType, input.tex + float2(0.0f, texelSize * 2.0f)) * weight2;

//	        // Set the alpha channel to one.
//            colour.a = 1.0f;
//           //colour = (0, 0, 0, 0);
//        }
//    }

//    return colour;
//}

//float4 main(InputType input) : SV_TARGET
//{
//    //input.normal = (CalcNormal(input.tex.xy, heightTexture, SampleType).x, CalcNormal(input.tex.xy, heightTexture, SampleType).y, CalcNormal(input.tex.xy, heightTexture, SampleType).z);
//    //input.position.y += getHeight(input.tex.xy, heightTexture, SampleType);
    
//    float depthValue;
//    // Get the depth value of the pixel by dividing the Z pixel depth by the homogeneous W coordinate.
//    depthValue = input.tex.z / input.tex.w;
//    float4 colour = { 0, 0, 0, 1 };
//    colour = shaderTexture.Sample(SampleType, input.tex.xy);

//    // Depth Value gives a minute difference, to extrapolate this difference:
//    // First 10% of the depth buffer color red.
//    if (depthValue < 0.9f)
//    {
//        colour = float4(1.0, 0.0f, 0.0f, 1.0f);
//    }

//    // The next 0.025% portion of the depth buffer color green.
//    if (depthValue > 0.9f)
//    {
//        colour = float4(0.0, 1.0f, 0.0f, 1.0f);
//    }

//    // The remainder of the depth buffer color blue.
//    if (depthValue > 0.925f)
//    {
//        colour = float4(0.0, 0.0f, 1.0f, 1.0f);
//    }

//    //return float4(1.0, 0.0f, 0.0f, 1.0f);

//    //return float4(1.0f - depthValue, 1.0f - depthValue, 1.0f - depthValue, 1.0f);
//    return colour;
//}
