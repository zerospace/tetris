//
//  Shaders.metal
//  Tetris
//
//  Created by Oleksandr Fedko on 11.05.2023.
//

#include <metal_stdlib>
#include "Lighting.h"
#include "Vertex.h"

using namespace metal;

vertex VertexOut vertexShader(Vertex in [[stage_in]], constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * position;
    out.normal = in.normal;
    out.color = in.color;
    out.uv = in.uv;
    out.worldPosition = (uniforms.modelMatrix * position).xyz;
    out.worldNormal = uniforms.normalMatrix * in.normal;
    
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               constant Params &params [[buffer(BufferIndexParams)]],
                               constant Light *lights [[buffer(BufferIndexLight)]])
{
    float3 normalDirection = normalize(in.worldNormal);
    float3 color = phongLightning(normalDirection, in.worldPosition, params, lights, in.color);
    return float4(color, 1.0);
}

