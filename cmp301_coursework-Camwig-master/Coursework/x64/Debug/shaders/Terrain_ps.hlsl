// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)
#include "lighting.hlsli"

#define NUM_LIGHTS 3

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

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    float3 viewVectror : TEXCOOORD2;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
//float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
//{
//    float intensity = saturate(dot(normal, lightDirection));
//    float4 colour = saturate(diffuse * intensity);
//    return colour;
//}

//float getHeight(float2 _uv,Texture2D texture0,SamplerState sampler0)
//{
//    float height = texture0.SampleLevel(sampler0, _uv, 0).x;
//    return height * 30.0f;
//    //return lerp(0, 20.f, height);
//}

//float3 CalcNormal(float2 uv, Texture2D texture0, SamplerState sampler0)
//{   
//    //current dimension of the texture since the current texture is a square the dimensions are that of a equal value
//    float texture_dimensions = 256.0f;
//    //will check this to offset any issues with the vertices lining up with the texture
//    float uv_offset = 3.0f / texture_dimensions;
//    //world space will operate in larger scale than 0 to 1 such as 1 to 100 thus the multiple
//    float world_offset = uv_offset * 100.0f;
    
//    //gets the height of the texture to the north of the current vertex moore neighbourhood
//    float North_height = getHeight(float2(uv.x, uv.y + uv_offset),texture0,sampler0);
//    //does this for the other three cardinal directions
//    float South_height = getHeight(float2(uv.x, uv.y - uv_offset), texture0, sampler0);
//    float East_height = getHeight(float2(uv.x + uv_offset, uv.y), texture0, sampler0);
//    float West_height = getHeight(float2(uv.x - uv_offset, uv.y), texture0, sampler0);
//    //get the height of the texture at the current vertex
//    float Current_height = getHeight(uv, texture0, sampler0);
    
//    //Calculate the tangents direction of the four cardinal directions compared to the current vertex normal
//    float3 North_tan = normalize(float3(0, North_height - Current_height, 1.0 * world_offset));
//    float3 South_tan = normalize(float3(0, South_height - Current_height, -1.0 * world_offset));
//    float3 East_tan = normalize(float3(1.0 * world_offset, East_height - Current_height,0));
//    float3 West_tan = normalize(float3(-1.0 * world_offset, West_height - Current_height, 0));
    
//    //Perform the cross product between the major cardinal directions normals such as south and west, north and east to get the accurate normal of the current vertex depending on the height of the texture
//    return float3(cross(North_tan, East_tan) - (cross(North_tan, West_tan)) - (cross(South_tan, East_tan) + (cross(South_tan, West_tan)) / 4.0f));

//}

// Calculate lighting intensity based on direction and normal. Combine with light colour.


//float4 calcSpecular(float3 lightDirection, float3 normal, float3 viewVector, float4 specularColour, float specularPower)
//{
//    float3 halfway = normalize(lightDirection + viewVector);
//    float specularIntensity = pow(max(dot(normal, halfway), 0.0f), specularPower);
//    return saturate(specularColour * specularIntensity);
//}

//float4 calcAttenuation(float distance, float constantfactor, float linearFactor, float quadraticfactor)
//{
//    float attenuation = 1.f / ((constantfactor + (linearFactor * distance) + (quadraticfactor * pow(distance, 2))));
//    return attenuation;
//}

float4 main(InputType input) : SV_TARGET
{
    //Try implementing a for loop to loop through instead
	
    float4 textureColour = texture1.Sample(sampler0, input.tex);
    float3 lightVector;
    float attenuation;
    float4 lightColour[NUM_LIGHTS];
    float4 final_colour = float4(0.0f, 0.0f, 0.0f, 1.0f);
    input.normal = CalcNormal(input.tex,texture0, sampler0);
    
    
    if (NUM_LIGHTS != 0)
    {
        for (int i = 0; i < NUM_LIGHTS; i++)
        {
            attenuation = 0.0f;
            lightColour[i] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);
            
            if (position[i].w == 1.0f)
            {
              //  lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);
	
                // 0.5,0.125,0.0f
                attenuation = calcAttenuation(length(lightVector), 0.0f, 0.005f, 0.0f);
	
                lightVector = normalize(lightVector);
	
                lightColour[i] = ambient + attenuation * calculateLighting(lightVector, input.normal, diffuse[i], position[i]);
	
                lightColour[i] += calcSpecular(lightVector, input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            else if (position[i].w == 2.0f)
            {
               // lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);;
	
                attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
	
                lightVector = normalize(lightVector);
	
                lightColour[i] = ambient + attenuation * calculateLighting(float3(direction[i].x, direction[i].y, direction[i].z), input.normal, diffuse[i], position[i]);
	
                lightColour[i] += calcSpecular(float3(direction[i].x, direction[i].y, direction[i].z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
                
               // lightColour[i] *= calcSpecular(lightVector, input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
                
                /*            {
                lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);;
	
                attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
	
                lightVector = normalize(lightVector);
	
                lightColour[i] = ambient + attenuation * calculateLighting(float3(direction.x,direction.y,direction.z), input.normal, diffuse[i], position[i]);
	
                lightColour[i] *= calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }*/
            }
            else if (position[i].w == 3.0f)
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
                    lightColour[i] *= /*ambient + attenuation **/ pow((max(dot(-lightVector.xyz, float3(direction[i].x, direction[i].y, direction[i].z)), 0.0f)), 2.5f);
                }
                
                //lightColour[i] += calcSpecular(float3(direction[i].x, direction[i].y, direction[i].z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
                //lightColour[i] *= calcSpecular(lightVector, input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            
            final_colour.xyz += lightColour[i].xyz;

        }
        
        //return lightColour[0] * lightColour[1] * lightColour[2] * textureColour;
    }
    if (getHeight(input.tex, texture0, sampler0) <= 6.0f)
    {
        textureColour = lerp(texture1.Sample(sampler0, input.tex), texture2.Sample(sampler0, input.tex),0.75);
    }
    //return float4(abs(input.normal), 1);
   return final_colour * textureColour;
}