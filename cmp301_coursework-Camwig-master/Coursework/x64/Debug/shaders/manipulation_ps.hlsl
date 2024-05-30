// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
Texture2D texture1 : register(t1);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
    float4 diffuseColour;
    float3 lightDirection;
    float padding;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    float4 colour = saturate(diffuse * intensity);
    return colour;
}

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
	
    float uvOffset = 3.0f / tw; //sub sampling half the min rate
	//Should be passed in const buffer
	//if we go from zero to hundred units in mesh to 0.0f - 1.0f uv
    float worldstep = 100.0f * uvOffset;
	
    float heightN = getHeight(float2(uv.x, uv.y + uvOffset));
    float heightS = getHeight(float2(uv.x, uv.y - uvOffset));
    float heightE = getHeight(float2(uv.x + uvOffset, uv.y));
    float heightW = getHeight(float2(uv.x - uvOffset, uv.y));
    float height = getHeight(uv);
	
    float3 tan1 = normalize(float3(1.0f * worldstep, heightE - height, 0));
    float3 tan2 = normalize(float3(-1.0f * worldstep, heightW - height, 0));
    float3 bitan1 = normalize(float3(0, heightN - height, 1.0f * worldstep));
    float3 bitan2 = normalize(float3(0, heightS - height, -1.0f * worldstep));
	
    return float3((cross(bitan1, tan1) - cross(bitan1, tan2) - cross(bitan2, tan1) + cross(bitan2, tan2)) / 4.0f);

}

float4 main(InputType input) : SV_TARGET
{
    float4 textureColour;
    float4 lightColour;
    input.normal = CalcNormal(input.tex);
	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
    textureColour = texture1.Sample(sampler0, input.tex);
    lightColour = calculateLighting(-lightDirection, input.normal, diffuseColour);
	
    
    return lightColour * textureColour;
   // return float4(input.normal, 1);
}