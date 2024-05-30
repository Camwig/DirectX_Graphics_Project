float4 calculateLighting(float3 lightDirection, float3 normal, float4 ldiffuse, float4 position)
{
    float intensity;
    float4 colour;
    //Diffrent types of lights need diffrent calculations for their colour values
    //Checks what type of light it is via the use of the position.w value
    if (position.w == 1.0f)
    {
        intensity = saturate(dot(normal, lightDirection));
        colour = saturate(ldiffuse * intensity);
    }
    else if (position.w == 2.0f)
    {
        intensity = saturate(dot(normal, -lightDirection));
        colour = saturate(ldiffuse * intensity);
    }
    else if (position.w == 3.0f)
    {
        float intensity = saturate(dot(normal, lightDirection));
        colour = 0.25f + saturate(ldiffuse * intensity);
    }
    return colour;
}

float getHeight(float2 _uv, Texture2D texture0, SamplerState sampler0, float offset)
{
    //Sample the height map texture and then multiplies it by the offset value
    //Which then returns the height value
    float3 height = texture0.SampleLevel(sampler0, _uv, 0).x;
    return height.r * offset;
}

float getHeight2(float2 _uv, Texture2D texture0, Texture2D texture1, SamplerState sampler0,float dt, float offset)
{
    //Lerps between the two height maps for the water mesh to get the height and then is multiplied by the offset value and returns the height
    float height = lerp(texture0.SampleLevel(sampler0, _uv, 0).x, texture1.SampleLevel(sampler0, _uv, 0).x,dt);
    return height * (5.0f + offset)/2.0f;
}

float3 CalcNormal(float2 uv, Texture2D texture0, SamplerState sampler0 , float offset)
{
    
    //current dimension of the texture since the current texture is a square the dimensions are that of a equal value
    float texture_dimensions = 256.0f;
    float val;
    texture0.GetDimensions(0, texture_dimensions, texture_dimensions, val);
    //will check this to offset any issues with the vertices lining up with the texture
    float uv_offset = 3.0f / texture_dimensions;
    //world space will operate in larger scale than 0 to 1 such as 1 to 100 thus the multiple
    float world_offset = uv_offset * 100.0f;
    
    //gets the height of the texture to the north of the current vertex moore neighbourhood
    float North_height = getHeight(float2(uv.x, uv.y + uv_offset), texture0, sampler0,offset);
    //does this for the other three cardinal directions
    float South_height = getHeight(float2(uv.x, uv.y - uv_offset), texture0, sampler0,offset);
    float East_height = getHeight(float2(uv.x + uv_offset, uv.y), texture0, sampler0,offset);
    float West_height = getHeight(float2(uv.x - uv_offset, uv.y), texture0, sampler0,offset);
    //get the height of the texture at the current vertex
    float Current_height = getHeight(uv, texture0, sampler0, offset);
    
    //Calculate the tangents direction of the four cardinal directions compared to the current vertex normal
    float3 East_tan = normalize(float3(1.0f * world_offset, East_height - Current_height, 0));
    float3 West_tan = normalize(float3(-1.0f * world_offset, West_height - Current_height, 0));
    float3 North_tan = normalize(float3(0, North_height - Current_height, 1.0f * world_offset));
    float3 South_tan = normalize(float3(0, South_height - Current_height, -1.0f * world_offset));
	
    //Perform the cross product between the major cardinal directions normals such as south and west, north and east to get the accurate normal of the current vertex depending on the height of the texture
    return float3((cross(North_tan, East_tan) - cross(North_tan, West_tan) - cross(South_tan, East_tan) + cross(South_tan, West_tan)) / 4.0f);

}

float3 CalcNormal2(float2 uv, Texture2D texture0, Texture2D texture1, SamplerState sampler0, float dt)
{
    //current dimension of the texture since the current texture is a square the dimensions are that of a equal value
    float texture_dimensions = 256.0f;
    //will check this to offset any issues with the vertices lining up with the texture
    float uv_offset = 3.0f / texture_dimensions;
    //world space will operate in larger scale than 0 to 1 such as 1 to 100 thus the multiple
    float world_offset = uv_offset * 100.0f;
    
    //gets the height of the texture to the north of the current vertex moore neighbourhood
    float North_height = getHeight(float2(uv.x, uv.y + uv_offset), texture0, sampler0, 30.0f);
    //does this for the other three cardinal directions
    float South_height = getHeight(float2(uv.x, uv.y - uv_offset), texture0, sampler0, 30.0f);
    float East_height = getHeight(float2(uv.x + uv_offset, uv.y), texture0, sampler0, 30.0f);
    float West_height = getHeight(float2(uv.x - uv_offset, uv.y), texture0, sampler0, 30.0f);
    //get the height of the texture at the current vertex
    float Current_height = getHeight(uv, texture0, sampler0,30.0f);
    
    float North_height2 = getHeight(float2(uv.x, uv.y + uv_offset), texture1, sampler0, 30.0f);
    //does this for the other three cardinal directions
    float South_height2 = getHeight(float2(uv.x, uv.y - uv_offset), texture1, sampler0, 30.0f);
    float East_height2 = getHeight(float2(uv.x + uv_offset, uv.y), texture1, sampler0, 30.0f);
    float West_height2 = getHeight(float2(uv.x - uv_offset, uv.y), texture1, sampler0, 30.0f);
    //get the height of the texture at the current vertex
    float Current_height2 = getHeight(uv, texture0, sampler0,30.0f);
    
    //Cross multiplies the heights to get the apprpirate height of the water mesh
    float North_height3 = cross(North_height, North_height2);
    float South_height3 = cross(South_height, South_height2);
    float East_height3 = cross(East_height, East_height2);
    float West_height3 = cross(West_height, West_height2);
    float Current_height3 = cross(Current_height, Current_height2);
    
    //Calculate the tangents direction of the four cardinal directions compared to the current vertex normal
    float3 East_tan = normalize(float3(1.0f * world_offset, East_height3 - Current_height3, 0));
    float3 West_tan = normalize(float3(-1.0f * world_offset, West_height3 - Current_height3, 0));
    float3 North_tan = normalize(float3(0, North_height3 - Current_height3, 1.0f * world_offset));
    float3 South_tan = normalize(float3(0, South_height3 - Current_height3, -1.0f * world_offset));
	
    //Perform the cross product between the major cardinal directions normals such as south and west, north and east to get the accurate normal of the current vertex depending on the height of the texture
    return float3((cross(North_tan, East_tan) - cross(North_tan, West_tan) - cross(South_tan, East_tan) + cross(South_tan, West_tan)) / 4.0f);

}

float4 calcSpecular(float3 lightDirection, float3 normal, float3 viewVector, float4 specularColour, float specularPower)
{
    //Gets the halfway mark by normalizing the light direction added to the view vector
    float3 halfway = normalize(lightDirection + viewVector);
    //Gets the specular power by calculating the dot product of the normal and the halfway value and then multiplying that value by the specular power
    float specularIntensity = pow(max(dot(normal, halfway), 0.0f), specularPower);
    return saturate(specularColour * specularIntensity);
}

float4 calcAttenuation(float distance, float constantfactor, float linearFactor, float quadraticfactor)
{
    //Calculates the attenuation
    float attenuation = 1.f / ((constantfactor + (linearFactor * distance) + (quadraticfactor * pow(distance, 2))));
    return attenuation;
}


//Shadow functions

bool hasDepthData(float2 uv)
{
    //Checks if the uv values have depth data
    if (uv.x < 0.f || uv.x > 1.f || uv.y < 0.f || uv.y > 1.f)
    {
        return false;
    }
    return true;
}

bool isInShadow(Texture2D sMap, float2 uv, float4 lightViewPosition, float bias, SamplerState shadowSampler)
{
    // Sample the shadow map (get depth of geometry)
    float depthValue = sMap.Sample(shadowSampler, uv).r;
	// Calculate the depth from the light.
    float lightDepthValue = lightViewPosition.z / lightViewPosition.w;
    lightDepthValue -= bias;

	// Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
    if (lightDepthValue < depthValue)
    {
        return false;
    }
    return true;
}

float2 getProjectiveCoords(float4 lightViewPosition)
{
    // Calculate the projected texture coordinates.
    float2 projTex = lightViewPosition.xy / lightViewPosition.w;
    projTex *= float2(0.5, -0.5);
    projTex += float2(0.5f, 0.5f);
    return projTex;
}

