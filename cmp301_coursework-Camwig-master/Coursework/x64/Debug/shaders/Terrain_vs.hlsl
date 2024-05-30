// Light vertex shader
// Standard issue vertex shader, apply matrices, pass info to pixel shader

#include "lighting.hlsli"

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

cbuffer CameraBuffer : register(b2)
{
    float3 cameraPosition;
    float padding3;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    float3 viewVector : TEXCOORD2;
    float3 LightPosition1 : TEXCOORD3;
};

//float getHeight(float2 _uv)
//{
//    float height = texture0.SampleLevel(sampler0, _uv, 0).x;
//    return height * 30.0f;
//    //return lerp(0, 20.f, height);
//}

//float3 CalcNormal(float2 uv)
//{
//    //current dimension of the texture since the current texture is a square the dimensions are that of a equal value
//    float texture_dimensions = 256.0f;
//    //will check this to offset any issues with the vertices lining up with the texture
//    float uv_offset = 3.0f / texture_dimensions;
//    //world space will operate in larger scale than 0 to 1 such as 1 to 100 thus the multiple
//    float world_offset = uv_offset * 100.0f;
    
//    //gets the height of the texture to the north of the current vertex moore neighbourhood
//    float North_height = getHeight(float2(uv.x, uv.y + uv_offset));
//    //does this for the other three cardinal directions
//    float South_height = getHeight(float2(uv.x, uv.y - uv_offset));
//    float East_height = getHeight(float2(uv.x + uv_offset, uv.y));
//    float West_height = getHeight(float2(uv.x - uv_offset, uv.y));
//    //get the height of the texture at the current vertex
//    float Current_height = getHeight(uv);
    
//    //Calculate the tangents direction of the four cardinal directions compared to the current vertex normal
//    float3 North_tan = normalize(float3(0, North_height - Current_height, 1.0 * world_offset));
//    float3 South_tan = normalize(float3(0, South_height - Current_height, -1.0 * world_offset));
//    float3 East_tan = normalize(float3(1.0 * world_offset, East_height - Current_height, 0));
//    float3 West_tan = normalize(float3(-1.0 * world_offset, West_height - Current_height,0));
    
//    //Perform the cross product between the major cardinal directions normals such as south and west, north and east to get the accurate normal of the current vertex depending on the height of the texture
//    return float3(cross(North_tan, East_tan) - (cross(North_tan, West_tan)) - (cross(South_tan, East_tan) + (cross(South_tan, West_tan)) / 4.0f));

//}

OutputType main(InputType input)
{
    OutputType output;

	/*To elaborate one what max has suggested, your texture_uv is already given to you and are the texture coordinates of the current vertex being looked at (intput.tex),
	so that is what you'll want to use in the samplelevel function. The function does not return your texture coordinates. 
	It's essentially the same as sampling in the pixel shader, just with a different name!*/
	
	//offset position based on sine wave
    //input.position.xyz += (amplitude * sin((2 * 3.14159 / frequency) * (input.position.x + time * speed))) * (input.normal);
	
    //input.position.y += amplitude * sin((2 * 3.14159 / frequency) * (input.position.z + time * speed));
	
    //float3 sine_wave = (amplitude * sin((2 * 3.14159 / frequency) * (input.position.x + time * speed)));
	
    //input.position.x += sine_wave * (texture_uv);
    input.position.w = 1.0f;
    
    output.position = input.position;
    output.position.y += getHeight(input.tex,texture0, sampler0);
	
	//modify normals
    //input.normal += float3(amplitude * -cos((2 * 3.14159 / frequency) * (input.position.x + time * speed)), 1, 0);
    //input.normal += float3(amplitude * -sin((2 * 3.14159 / frequency) * (input.position.z + time * speed)), 1, 0);

	// Calculate the position of the vertex against the world, view, and projection matrices.
    //output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    float4 worldPosition = mul(input.position, worldMatrix);
    output.viewVector = cameraPosition.xyz - worldPosition.xyz;
    output.viewVector = normalize(output.viewVector);
    
    // Store the texture coordinates for the pixel shader.
    output.tex = input.tex;
	
	// Calculate the normal vector against the world matrix only and normalise.
    //output.normal = mul(CalcNormal(input.tex), (float3x3) worldMatrix);
    //output.normal = normalize(output.normal);
    
    output.worldPosition = mul(input.position, worldMatrix).xyz;

    return output;
}