float4 calculateLighting(float3 lightDirection, float3 normal, float4 ldiffuse, float4 position)
{
    float intensity;
    float4 colour;
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

float getHeight(float2 _uv, Texture2D texture0, SamplerState sampler0)
{
    float height = texture0.SampleLevel(sampler0, _uv, 0).x;
    return height * 30.0f;
    //return lerp(0, 20.f, height);
}

float getHeight2(float2 _uv, Texture2D texture0, Texture2D texture1, SamplerState sampler0,float dt, float offset)
{
    float height = lerp(texture0.SampleLevel(sampler0, _uv, 0).x, texture1.SampleLevel(sampler0, _uv, 0).x,dt);
    return height * (5.0f + offset)/2.0f;
    //return lerp(0, 20.f, height);
}

float3 CalcNormal(float2 uv, Texture2D texture0, SamplerState sampler0)
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
    float North_height = getHeight(float2(uv.x, uv.y + uv_offset), texture0, sampler0);
    //does this for the other three cardinal directions
    float South_height = getHeight(float2(uv.x, uv.y - uv_offset), texture0, sampler0);
    float East_height = getHeight(float2(uv.x + uv_offset, uv.y), texture0, sampler0);
    float West_height = getHeight(float2(uv.x - uv_offset, uv.y), texture0, sampler0);
    //get the height of the texture at the current vertex
    float Current_height = getHeight(uv, texture0, sampler0);
    
    //North_height /= 2.0f;
    //South_height /= 2.0f;
    //East_height /= 2.0f;
    //West_height /= 2.0f;
    //Current_height /= 2.0f;
    
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
    
    //Texture2D new_texture = lerp(texture0.SampleLevel(sampler0, uv, 0).x, texture1.SampleLevel(sampler0, uv, 0).x, dt);
    
    //gets the height of the texture to the north of the current vertex moore neighbourhood
    float North_height = getHeight(float2(uv.x, uv.y + uv_offset), texture0, sampler0);
    //does this for the other three cardinal directions
    float South_height = getHeight(float2(uv.x, uv.y - uv_offset), texture0, sampler0);
    float East_height = getHeight(float2(uv.x + uv_offset, uv.y), texture0, sampler0);
    float West_height = getHeight(float2(uv.x - uv_offset, uv.y), texture0, sampler0);
    //get the height of the texture at the current vertex
    float Current_height = getHeight(uv, texture0, sampler0);
    
    float North_height2 = getHeight(float2(uv.x, uv.y + uv_offset), texture1, sampler0);
    //does this for the other three cardinal directions
    float South_height2 = getHeight(float2(uv.x, uv.y - uv_offset), texture1, sampler0);
    float East_height2 = getHeight(float2(uv.x + uv_offset, uv.y), texture1, sampler0);
    float West_height2 = getHeight(float2(uv.x - uv_offset, uv.y), texture1, sampler0);
    //get the height of the texture at the current vertex
    float Current_height2 = getHeight(uv, texture0, sampler0);
    
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
    float3 halfway = normalize(lightDirection + viewVector);
    float specularIntensity = pow(max(dot(normal, halfway), 0.0f), specularPower);
    return saturate(specularColour * specularIntensity);
}

float4 calcAttenuation(float distance, float constantfactor, float linearFactor, float quadraticfactor)
{
    float attenuation = 1.f / ((constantfactor + (linearFactor * distance) + (quadraticfactor * pow(distance, 2))));
    return attenuation;
}