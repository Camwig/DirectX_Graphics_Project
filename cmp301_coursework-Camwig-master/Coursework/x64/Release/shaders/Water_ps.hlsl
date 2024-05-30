// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

#include "lighting.hlsli"

#define NUM_LIGHTS 4

Texture2D texture0 : register(t0);
Texture2D texture1 : register(t1);
Texture2D texture2 : register(t2);
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

cbuffer timerBuffer : register(b1)
{
    float time;
    float3 padding3;
    float height;
    float3 padding2;
}

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    float3 viewVectror : TEXCOOORD2;
};

float4 main(InputType input) : SV_TARGET
{
    float4 textureColour = texture0.Sample(sampler0, input.tex);
    float3 lightVector;
    float attenuation;
    float4 lightColour[NUM_LIGHTS];
    float4 final_colour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    
    if (NUM_LIGHTS != 0)
    {
        for (int i = 0; i < NUM_LIGHTS; i++)
        {
            attenuation = 0.0f;
            lightVector = float3(0.0f, 0.0f, 0.0f);
            lightColour[i] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);
            
            if (position[i].w == 1.0f)
            {
                //Light is in fact a point light
        
                //Calculate the attenuation
                attenuation = calcAttenuation(length(lightVector), 0.0f, 0.005f, 0.0f);
	
                lightVector = normalize(lightVector);
	            
                //Calculates the lighting
                lightColour[i] = ambient + attenuation * calculateLighting(lightVector, input.normal, diffuse[i], position[i]);
	            
                //Adds the specular values
                lightColour[i] += calcSpecular(lightVector, input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            else if (position[i].w == 2.0f)
            {
                //Light is in fact a directional light
        
                //Calculate the attenuation
                attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
	
                lightVector = normalize(lightVector);
	            
                //Calculates the lighting
                lightColour[i] = ambient + attenuation * calculateLighting(float3(direction[i].x, direction[i].y, direction[i].z), input.normal, diffuse[i], position[i]);
	            
                //Adds the specular values
                lightColour[i] += calcSpecular(float3(direction[i].x, direction[i].y, direction[i].z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            else if (position[i].w == 3.0f)
            {

                attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
    
                //Find the distance between the light pos and pixel pos
                float d = length(lightVector.xyz);
    
                //If pixel is too far, return pixel color with ambient light
                if (d > 10.0f)
                {
                //lightColour = (diffuseColour * 0.25f);
                    lightColour[i] = 0.25 + calculateLighting(lightVector.xyz, input.normal, diffuse[i], position[i]);
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
                    lightColour[i] += diffuse[i];
        
                    //Calculate falloff from center to edge of pointlight cone
                    lightColour[i] *= ambient + attenuation * pow((max(dot(-lightVector.xyz, float3(direction[i].x, direction[i].y, direction[i].z)), 0.0f)), 2.5f);
                }
                lightColour[i] += calcSpecular(float3(direction[i].x, direction[i].y, direction[i].z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            
            final_colour.xyz += lightColour[i].xyz;

        }
    }
    return final_colour * textureColour;
}