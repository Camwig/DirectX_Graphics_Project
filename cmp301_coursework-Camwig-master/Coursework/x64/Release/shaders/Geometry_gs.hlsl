cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix ViewMatrix;
    matrix projectionMatrix;
};

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

[maxvertexcount(6)]
void main(triangle InputType input[3],inout LineStream<OutputType> lStream)
{
    OutputType output;
    
    ////Move the first vertex away from the point position
    //output.position = input[0].position + float4(0.0f, 1.0f, 0.0f, 0.0f);
    //output.position = mul(output.positon, worldMatrix);
    //output.position = mul(output.positon, ViewMatrix);
    //output.position = mul(output.positon, projectionMatrix);
    
    //output.tex = input[0].tex;
    
    //output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    //output.normal = normalize(output.normal);
    
    //tristream.Append(output); // append first vertex to stream
    
    ////Move the second vertex away from the point position
    //output.position = input[0].position + float4(-1.0f, 0.0f, 0.0f, 0.0f);
    //output.position = mul(output.positon, worldMatrix);
    //output.position = mul(output.positon, ViewMatrix);
    //output.positon = mul(output.positon, projectionMatrix);
    //output.tex = input[0].tex;
    //output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    //output.normal = normalize(output.normal);
    
    //tristream.Append(output); //append second vertex to stream
    
    ////Move the third vertex away from the point position
    //output.position = input[0].position + float4(1.0f, 0.0f, 0.0f, 0.0f);
    //output.position = mul(output.positon, worldMatrix);
    //output.position = mul(output.positon, ViewMatrix);
    //output.position = mul(output.positon, projectionMatrix);
    //output.normal = mul(input[0].normal, (float3x3) worldMatrix);
    //output.normal = normalize(output.normal);
    
    //tristream.Append(output); //append third vertex to stream
    
    ////next strip
    //tristream.RestartStrip();
    
    for (int i = 0; i < 3; i++)
    {
        float3 P = input[i].position.xyz;
        float3 N = input[i].normal.xyz;
        float3 P2 = P + (N / 2);
        
        output.position = mul(float4(P, 1.0f), worldMatrix);
        output.position = mul(output.position, ViewMatrix);
        output.position = mul(output.position, projectionMatrix);
        output.tex = input[i].tex;
        
        output.normal = mul(N, (float3x3) worldMatrix);
        output.normal = normalize(output.normal);
        lStream.Append(output);
        
        output.position = mul(float4(P2, 1.0f), worldMatrix);
        output.position = mul(output.position, ViewMatrix);
        output.position = mul(output.position, projectionMatrix);
        lStream.Append(output);
        lStream.RestartStrip();
    }

}