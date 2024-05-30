

#include "lighting.hlsli"

#define NUM_LIGHTS 3

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

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
    float3 worldPosition : TEXCOORD1;
    float3 viewVectror : TEXCOOORD2;
};

float4 PerformLighting(InputType input, float4 lightColour, float attenuation, float3 lightVector, float4 position, float4 direction, float4 diffuse, float4 ambient, float specular_power)
{
    if (position.w == 1.0f)
    {
        attenuation = calcAttenuation(length(lightVector), 0.5, 0.125, 0.0f);
	
        lightVector = normalize(lightVector);
	
        lightColour = ambient + attenuation * calculateLighting(lightVector, input.normal, diffuse, position);
	
        lightColour += calcSpecular(lightVector, input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
    }
    else if (position.w == 2.0f)
    {

        attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
	
        lightVector = normalize(lightVector);
	
        lightColour = ambient + attenuation * calculateLighting(float3(direction.x, direction.y, direction.z), input.normal, diffuse, position);
	
        lightColour += calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);

    }
    else if (position.w == 3.0f)
    {
        //lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);
    
        //Create the vector between light position and pixels position
        //float3 LightToPixelVec = position[i].xyz - input.worldPosition;
                
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
                
        lightColour += calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
    }
    
    return lightColour;
}

float4 main(InputType input) : SV_TARGET
{
    //Try implementing a for loop to loop through instead
	
    float4 textureColour = texture0.Sample(sampler0, input.tex);
    float3 lightVector;
    float attenuation;
    float4 lightColour[NUM_LIGHTS];
    float4 final_colour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    //input.normal = CalcNormal(input.tex, texture0, sampler0);
    
    
    if (NUM_LIGHTS > 0)
    {
        for (int i = 0; i < NUM_LIGHTS; i++)
        {
            attenuation = 0.0f;
            lightColour[i] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);
            
            final_colour.xyz += PerformLighting(input,lightColour[i],attenuation,lightVector,position[i],direction[i],diffuse[i],ambient,specularPower).xyz;

        }
        
        //return lightColour[0] * lightColour[1] * lightColour[2] * textureColour;
        return final_colour * textureColour;
    }
}