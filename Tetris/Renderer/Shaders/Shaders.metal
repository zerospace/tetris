//
//  Shaders.metal
//  Tetris
//
//  Created by Oleksandr Fedko on 11.05.2023.
//

#include <metal_stdlib>
#include "Lighting.h"

using namespace metal;

typedef struct {
    float3 position [[attribute(VertexAttributePosition)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
} Vertex;

typedef struct {
    float4 position [[position]];
    float3 normal;
    float3 worldPosition;
    float3 worldNormal;
} VertexOut;

vertex VertexOut vertexShader(Vertex in [[stage_in]], constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * position;
    out.normal = in.normal;
    out.worldPosition = (uniforms.modelMatrix * position).xyz;
    out.worldNormal = uniforms.normalMatrix * in.normal;
    
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               constant Params &params [[buffer(BufferIndexParams)]],
                               constant Light *lights [[buffer(BufferIndexLight)]])
{
    float3 normalDirection = normalize(in.worldNormal);
    float3 color = phongLightning(normalDirection, in.worldPosition, params, lights, float3(1.0, 1.0, 1.0));
    return float4(color, 1.0);
}

