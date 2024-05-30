
#include "lighting.hlsli"

#define NUM_LIGHTS 4

Texture2D shaderTexture : register(t0);
Texture2D depthMapTexture : register(t1);
Texture2D depthMapTexture2 : register(t2);

SamplerState diffuseSampler : register(s0);
SamplerState shadowSampler : register(s1);

cbuffer LightBuffer : register(b0)
{
    float4 ambient;
    float4 diffuse[NUM_LIGHTS];
    float4 position[NUM_LIGHTS];
    float4 direction[NUM_LIGHTS];
    float specularPower;
    float3 padding;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 lightViewPos : TEXCOORD1; //pass in world position and calculate this here
    float3 worldPosition : TEXCOOORD3;
    float3 viewVector : TEXCOORD4;
    float4 lightViewPos2 : TEXCOORD2;
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
        
        //Calculates the attenuation value
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
        //Add the specular value to the final lighting value
        lightColour += calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVector, float4(1, 1, 1, 1), specularPower);
    }
    
    return lightColour;
}

float4 main(InputType input) : SV_TARGET
{
    float3 lightVector;
    float attenuation = 0.0f;
    float4 lightColour[NUM_LIGHTS];
    float4 final_colour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    
    
    float shadowMapBias = 0.001f;
    float4 colour = float4(0.f, 0.f, 0.f, 1.f);
    float4 textureColour = shaderTexture.Sample(diffuseSampler, input.tex);

	// Calculate the projected texture coordinates.
    float2 pTexCoord = getProjectiveCoords(input.lightViewPos);
	
    //Shadow test. Is or isn't in shadow
    if (hasDepthData(pTexCoord))
    {
        // Has depth map data
        if (!isInShadow(depthMapTexture, pTexCoord, input.lightViewPos, shadowMapBias, shadowSampler))
        {
            lightColour[0] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[0].x, position[0].y, position[0].z) - input.worldPosition);
            
            //Call the Perform lighting and saturate the final value and add it to the colour value
            colour.xyz += saturate(PerformLighting(input, lightColour[0], attenuation, lightVector, position[0], direction[0], diffuse[0], ambient, specularPower).xyz);
        }
    }
    
    float2 pTexCoord2 = getProjectiveCoords(input.lightViewPos2);
    
    if (hasDepthData(pTexCoord2))
    {
        if (!isInShadow(depthMapTexture2, pTexCoord2, input.lightViewPos, shadowMapBias, shadowSampler))
        {
            lightColour[1] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[1].x, position[1].y, position[1].z) - input.worldPosition);
            
            colour.xyz += saturate(PerformLighting(input, lightColour[1], attenuation, lightVector, position[1], direction[1], diffuse[1], ambient, specularPower).xyz);
        }
    }
    
    //These lights dont have shadows attached so there is no need to perform the shadow calculation
    lightColour[2] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    lightVector = (float3(position[2].x, position[2].y, position[2].z) - input.worldPosition);
            
    colour.xyz += saturate(PerformLighting(input, lightColour[2], attenuation, lightVector, position[2], direction[2], diffuse[2], ambient, specularPower).xyz);
    
    lightColour[3] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    lightVector = (float3(position[3].x, position[3].y, position[3].z) - input.worldPosition);
            
    colour.xyz += saturate(PerformLighting(input, lightColour[3], attenuation, lightVector, position[3], direction[3], diffuse[3], ambient, specularPower).xyz);
    
    
    return colour * textureColour;
}