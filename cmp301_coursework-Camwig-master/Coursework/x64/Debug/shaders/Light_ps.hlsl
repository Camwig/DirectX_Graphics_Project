// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

#define NUM_LIGHTS 3

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
    float4 ambient;
    float4 diffuse[NUM_LIGHTS];
    float4 position[NUM_LIGHTS];
    float4 direction;
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
float4 calculateLighting(float3 lightDirection, float3 normal, float4 ldiffuse, float4 position)
{
    float intensity;
    if (position.w == 1.0f)
    {
        intensity = saturate(dot(normal, lightDirection));
    }
    else if (position.w == 2.0f)
    {
        intensity = saturate(dot(normal, -lightDirection));
    }
    float4 colour = saturate(ldiffuse * intensity);
    return colour;
}

float4 calcSpecular(float3 lightDirection, float3 normal, float3 viewVector, float4 specularColour, float specularPower)
{
    float3 halfway = normalize(lightDirection + viewVector);
    float specularIntensity = pow(max(dot(normal, halfway), 0.0f), specularPower);
    return saturate(specularColour * specularIntensity);
}

float4 calcAttenuation(float distance, float constantfactor, float linearFactor, float quadraticfactor)
{
    float attenuation = 1.f / ((constantfactor + (linearFactor * distance) + (quadraticfactor * pow(distance, 2))));
    return attenuation;
}

float4 main(InputType input) : SV_TARGET
{
    //Try implementing a for loop to loop through instead
	
    float4 textureColour = texture0.Sample(sampler0, input.tex);
    float3 lightVector;
    float attenuation;
    float4 lightColour[NUM_LIGHTS];
    float4 final_colour = float4(1.0f, 1.0f, 1.0f, 1.0f);
    
    
    if (NUM_LIGHTS > 0)
    {
        for (int i = 0; i < NUM_LIGHTS; i++)
        {
            attenuation = 0.0f;
            lightVector = float3(0.0f, 0.0f, 0.0f);
            lightColour[i] = float4(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (position[i].w == 1.0f)
            {
                lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);
	
                // 0.5,0.125,0.0f
                attenuation = calcAttenuation(length(lightVector), 0.0f, 0.005f, 0.0f);
	
                lightVector = normalize(lightVector);
	
                lightColour[i] = ambient + attenuation * calculateLighting(lightVector, input.normal, diffuse[i], position[i]);
	
                lightColour[i] *= calcSpecular(lightVector, input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            
            if (position[i].w == 2.0f)
            {
                lightVector = (float3(position[i].x, position[i].y, position[i].z) - input.worldPosition);;
	
                attenuation = calcAttenuation(length(lightVector), 0.5f, 0.125f, 0.0f);
	
                lightVector = normalize(lightVector);
	
                lightColour[i] = ambient + attenuation * calculateLighting(float3(direction.x, direction.y, direction.z), input.normal, diffuse[i], position[i]);
	
                lightColour[i] *= calcSpecular(float3(direction.x, direction.y, direction.z), input.normal, input.viewVectror, float4(1, 1, 1, 1), specularPower);
            }
            
            final_colour *= lightColour[i];

        }
        
        //return lightColour[0] * lightColour[1] * lightColour[2] * textureColour;
        return final_colour * textureColour;
    }
}