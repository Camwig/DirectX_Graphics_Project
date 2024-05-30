
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
    //float4 colour;
    //colour = BlurTexture.Sample(SampleType, input.tex.xy);
    //return colour;
    //float focal_length = DepthTexture.Sample(SampleType, float2(0.5f,0.5f));
    float focal_length = 0.25f;
    float4 distanceToFocalPlane = DepthTexture.Sample(SampleType, input.tex);
    //return distanceToFocalPlane;

    
    float4 new_colour1, new_colour2;
    
    new_colour1 = (BlurTexture.Sample(SampleType, input.tex.xy)) /** 0.25f*/;
    new_colour2 = (shaderTexture.Sample(SampleType, input.tex.xy)) /** 0.75f*/;
    
    new_colour1 = new_colour1 / 4;
    new_colour2 = (new_colour2 / 4) * 3;
    
    distanceToFocalPlane = focal_length - distanceToFocalPlane;
    
    distanceToFocalPlane = abs(distanceToFocalPlane);
    
    float4 new_colour = lerp(new_colour2, new_colour1, distanceToFocalPlane);
   
    return new_colour;
}