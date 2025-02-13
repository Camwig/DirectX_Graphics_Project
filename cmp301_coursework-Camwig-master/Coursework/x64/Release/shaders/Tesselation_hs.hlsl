// Tessellation HullShader
// Prepares control points for tessellation

cbuffer TessellationBuffer : register(b0)
{
    float4 Outside;
    float2 Inside;
    float2 padding;
    float3 cam_pos;
    float padding2;
};

cbuffer MatrixBuffer : register(b1)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
};

struct InputType
{
    float3 position : POSITION;
    float4 colour : COLOR;
};

struct ConstantOutputType
{
    float edges[4] : SV_TessFactor;
    float inside[2] : SV_InsideTessFactor;
};

struct OutputType
{
    float3 position : POSITION;
    float4 colour : COLOR;
};


ConstantOutputType PatchConstantFunction(InputPatch<InputType, 4> inputPatch, uint patchId : SV_PrimitiveID)
{
    ConstantOutputType pt;
    // Find center of patch in world space.
    float3 centerL = 0.25f * (inputPatch[0].position + inputPatch[1].position + inputPatch[2].position + inputPatch[3].position);
    float3 centerW = mul(float4(centerL, 1.0f), worldMatrix).xyz;
    float d = distance(centerW, cam_pos.xyz);
    // Tessellate the patch based on distance from the eye such that

    //Near enough to start the tesselation
    const float d0 = 10.0f;
    //Far enough away to not tesselat anymore
    const float d1 = 20.0f;
    //Calculate the distance so that is the near minus the centre of the camera over the far minus the centre of the camera
    float distance = saturate((d1 - d) / (d1 - d0));
    float tess = 64.0f;
    
    //Depending on the tesselation distance value the amount we tesselate by changes
    if (distance >= 0.75f)
    {
        tess = 64.0f;
    }
    else if (distance >= 0.5f)
    {
        tess = 32.0f;
    }
    else if (distance >= 0.25f)
    {
        tess = 16.0f;
    }
    else if (distance >= 0.125f)
    {
        tess = 8.0f;
    }
    else
    {
        tess = 1.0f;
    }
    
    // Uniformly tessellate the patch.
    pt.edges[0] = tess;
    pt.edges[1] = tess;
    pt.edges[2] = tess;
    pt.edges[3] = tess;

    // Set the tessellation factor for tessallating inside the triangle.
    pt.inside[0] = tess;
    pt.inside[1] = tess;
    return pt;
}


[domain("quad")]
[partitioning("integer")]
[outputtopology("triangle_ccw")]
[outputcontrolpoints(4)]
[patchconstantfunc("PatchConstantFunction")]
[maxtessfactor(64.0f)]
OutputType main(InputPatch<InputType, 4> patch, uint pointId : SV_OutputControlPointID, uint patchId : SV_PrimitiveID)
{
    OutputType output;

    // Set the position for this control point as the output position.
    output.position = patch[pointId].position;

    // Set the input colour as the output colour.
    output.colour = patch[pointId].colour;

    return output;
}
