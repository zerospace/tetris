//
//  Shaders.metal
//  Tetris
//
//  Created by Oleksandr Fedko on 11.05.2023.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

struct VertexIn {
    float4 position [[attribute(0)]];
};

vertex float4 vertexCube(const VertexIn vertex_in [[stage_in]]) {
    return vertex_in.position;
}

fragment float4 fragmentCube(constant FragmentUniforms &uniforms [[buffer(0)]]) {
    return float4(uniforms.brightness * float3(0.0, 1.0, 0.0), 1.0);
}

vertex VertexOut vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    Vertex in = vertexArray[vid];
    VertexOut out;
    
    out.color = in.color;
    out.pos = float4(in.pos.x, in.pos.y, 0.0, 1.0);
    
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]], constant FragmentUniforms &uniforms [[buffer(0)]]) {
    return  float4(uniforms.brightness * interpolated.color.rgb, interpolated.color.a);
}

