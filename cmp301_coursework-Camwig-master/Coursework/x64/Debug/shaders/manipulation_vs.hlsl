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
    //return lerp(0, 20.f, height);
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
    output.position.y += getHeight(input.tex);
	
	//modify normals
    //input.normal += float3(amplitude * -cos((2 * 3.14159 / frequency) * (input.position.x + time * speed)), 1, 0);
    //input.normal += float3(amplitude * -sin((2 * 3.14159 / frequency) * (input.position.z + time * speed)), 1, 0);

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