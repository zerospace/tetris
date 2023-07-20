//
//  Shaders.metal
//  Tetris
//
//  Created by Oleksandr Fedko on 11.05.2023.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float3 position [[attribute(VertexAttributePosition)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
} Vertex;

typedef struct {
    float4 position [[position]];
    float3 normal;
} VertexOut;

vertex VertexOut vertexShader(Vertex in [[stage_in]], constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * position;
    out.normal = in.normal;
    
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]], constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
//    float4 sky = float4(0.0, 0.0, 1.0, 1.0);
//    float4 ground = float4(0.0, 1.0, 0.0, 1.0);
//    float intensity = in.normal.y * 0.5 + 0.5;
//    return mix(ground, sky, intensity);
    return float4(float3(1.0, 0.0, 0.0) * float3(0.5, 0.5, 0.5), 1.0);
}

