
Texture2D shaderTexture : register(t0);
Texture2D BlurTexture : register(t1);
Texture2D DepthTexture : register(t2);

SamplerState SampleType : register(s0);

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
    //Calculate the focal length through sampling the depth texture at specific points in screen space
    //I used these values instead of 0.5 and 0.5 as it seemed to produce better results
    float focal_length = DepthTexture.Sample(SampleType, float2(0.5f, 1.0f));
    //Getting the distance from the focal point from the depth texture is just sampling the texture as normal
    float4 distanceToFocalPlane = DepthTexture.Sample(SampleType, input.tex.xy);
   
    float4 new_colour1, new_colour2;
    //Sample both the completley blurred texture and the unblurred texture
    new_colour1 = (BlurTexture.Sample(SampleType, input.tex.xy));
    new_colour2 = (shaderTexture.Sample(SampleType, input.tex.xy));
    //Get the value which we are going to use to lerp betweeen the blured and unblurred version by getting the absoloute value
    //of both the focal length and the distance to focal plane and subtracting the distnace to focal plane from the focal length
    float t_value = abs(focal_length.r) - abs(distanceToFocalPlane.r);
    
    //Multiply the t value by 300. This is done as the depth shader produces and incredibly small value and this helps with using it in the calculation
    t_value *= 300.0f;
    //Setup a simple clamping system so the t_value  will never be more than one and never be less than zero
    if (t_value > 1.0f)
    {
        t_value = 1.0f;
    }
    
    if (t_value < 0.0f)
    {
        t_value = 0.0f;
    }
    
    //Lerp between the blurred and unblurred scenes according to the t_value
    float4 new_colour = lerp(new_colour1, new_colour2, t_value);
    new_colour.w = 0.0f;
   
    return new_colour;
}