
#include "lighting.hlsli"

#define NUM_LIGHTS 4

Texture2D texture0 : register(t0);
Texture2D texture1 : register(t1);
Texture2D texture2 : register(t2);
Texture2D depthMapTexture : register(t3);
Texture2D depthMapTexture2 : register(t4);

SamplerState sampler0 : register(s0);
SamplerState shadowSampler : register(s1);

cbuffer LightBuffer : register(b0)
{
    float4 ambient;
    float4 diffuse[NUM_LIGHTS];
    float4 position[NUM_LIGHTS];
    float4 direction[NUM_LIGHTS];
    float specularPower;
    float3 padding;
    float height;
    float3 padding2;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOOORD1;
    float3 viewVector : TEXCOORD2;
    float4 lightViewPos : TEXCOORD3;
    float4 lightViewPos2 : TEXCOORD4;
};

float4 PerformLighting(InputType input, float4 lightColour, float attenuation, float3 lightVector, float4 position, float4 direction, float4 diffuse, float4 ambient, float specular_power)
{
    if (position.w == 1.0f)
    {
        //Light is in fact a point light
        
        //Calculate the attenuation
        attenuation = calcAttenuation(length(lightVector), 0.5, 0.125, 0.0f);
	
        lightVector = normalize(lightVector);
	    
        //Calculates the lighting
        lightColour = ambient + attenuation * calculateLighting(lightVector, input.normal, diffuse, position);
	    
        //Adds the specular values
        lightColour += calcSpecular(lightVector, input.normal, input.viewVector, float4(1, 1, 1, 1), specularPower);
    }
    else if (position.w == 2.0f)
    {
        //Light is in fact a directional light
        
        //Calculate the attenuation
        attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
	
        lightVector = normalize(lightVector);
	    
        //Calculates the lighting
        lightColour = ambient + attenuation * calculateLighting(float3(direction.x, direction.y, direction.z), input.normal, diffuse, position);
	    
        //Adds the specular values
        lightColour += calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVector, float4(1, 1, 1, 1), specularPower);

    }
    else if (position.w == 3.0f)
    { 
        //Light is in fact a spot light
        attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
    
        //Find the distance between the light pos and pixel pos
        float d = length(lightVector.xyz);
    
        //If pixel is too far, return pixel color with ambient light
        if (d > 10.0f)
        {
            //lightColour = (diffuseColour * 0.25f);
            lightColour = 0.25 + calculateLighting(lightVector.xyz, input.normal, diffuse, position);
        }
    
        //Turn lightToPixelVec into a unit length vector describing
        //the pixels direction from the lights position
        lightVector.xyz /= d;
    
        //Calculate how much light the pixel gets by the angle
        //in which the light strikes the pixels surface
        float HowMuchLight = dot(lightVector.xyz, input.normal);
    
        //If light is striking the front side of the pixel
        if (HowMuchLight > 0)
        {
            //Add light to the finalColor of the pixel
            lightColour += diffuse;
        
            //Calculate falloff from center to edge of pointlight cone
            lightColour *= ambient + attenuation * pow((max(dot(-lightVector.xyz, float3(direction.x, direction.y, direction.z)), 0.0f)), 2.5f);
        }
                
        lightColour += calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVector, float4(1, 1, 1, 1), specularPower);
    }
    
    return lightColour;
}

float4 main(InputType input) : SV_TARGET
{
    float4 textureColour = texture1.Sample(sampler0, input.tex);
    float3 lightVector;
    float attenuation = 0.0f;
    float4 lightColour[NUM_LIGHTS];
    float4 final_colour = float4(0.2f, 0.2f, 0.3f, 1.0f);
    float4 final_colour2 = float4(0.2f, 0.2f, 0.3f, 1.0f);
    input.normal = CalcNormal(input.tex, texture0, sampler0, height);
    
    
    
    float shadowMapBias = 0.005f;
    float4 colour = float4(0.f, 0.f, 0.f, 1.f);

	// Calculate the projected texture coordinates.
    float2 pTexCoord = getProjectiveCoords(input.lightViewPos);
	
    // Shadow test. Is or isn't in shadow
    if (hasDepthData(pTexCoord))
    {
        // Has depth map data
        if (!isInShadow(depthMapTexture, pTexCoord, input.lightViewPos, shadowMapBias, shadowSampler))
        {
            lightColour[0] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[0].x, position[0].y, position[0].z) - input.worldPosition);
            
            final_colour += saturate(PerformLighting(input, lightColour[0], attenuation, lightVector, position[0], direction[0], diffuse[0], ambient, specularPower));
        }
    }
    
    
    float2 pTexCoord2 = getProjectiveCoords(input.lightViewPos2);
    
    if (hasDepthData(pTexCoord2))
    {
        // Has depth map data
        if (!isInShadow(depthMapTexture2, pTexCoord2, input.lightViewPos2, shadowMapBias, shadowSampler))
        {
            lightColour[1] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[1].x, position[1].y, position[1].z) - input.worldPosition);
            
            final_colour += saturate(PerformLighting(input, lightColour[1], attenuation, lightVector, position[1], direction[1], diffuse[1], ambient, specularPower));
        }
    }
    
        //These lights dont have shadows attached so there is no need to perform the shadow calculation
    lightColour[2] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    lightVector = (float3(position[2].x, position[2].y, position[2].z) - input.worldPosition);
            
    final_colour += saturate(PerformLighting(input, lightColour[1], attenuation, lightVector, position[2], direction[2], diffuse[2], ambient, specularPower));
    
    lightColour[3] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    lightVector = (float3(position[3].x, position[3].y, position[3].z) - input.worldPosition);
            
    final_colour += saturate(PerformLighting(input, lightColour[3], attenuation, lightVector, position[3], direction[3], diffuse[3], ambient, specularPower));
    
    //Checks if the height of the terrain is below a cretain threshold it will lerp to a diffrent texture
    if (getHeight(input.tex, texture0, sampler0, height) <= 6.0f)
    {
        textureColour = lerp(texture1.Sample(sampler0, input.tex), texture2.Sample(sampler0, input.tex), 0.75);
    }
    
    return final_colour * textureColour;
}