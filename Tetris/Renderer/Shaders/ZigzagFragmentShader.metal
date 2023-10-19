//
//  ZigzagFragmentShader.metal
//  Tetris
//
//  Created by Oleksandr Fedko on 17.10.2023.
//
//  Author @patriciogv - 2015
//  https://thebookofshaders.com/edit.php#09/zigzag.frag

#include <metal_stdlib>
#include "Lighting.h"
#include "Vertex.h"

using namespace metal;

float2 mirrorTile(float2 st, float zoom) {
    st *= zoom;
    if (fract(st.y * 0.5) > 0.5) {
        st.x += 0.5;
        st.y = 1.0 - st.y;
    }
    return fract(st);
}

float fillY(float2 st, float pct, float antia) {
    return smoothstep(pct - antia, pct, st.y);
}

fragment float4 zigzagShader(VertexOut in [[stage_in]],
                             constant Params &params [[buffer(BufferIndexParams)]],
                             constant Light *lights [[buffer(BufferIndexLight)]])
{
    float2 st = mirrorTile(in.uv * float2(1.0, 2.0), 20.0);
    float x = st.x * 2.0;
    float a = floor(1.0 + sin(x * 3.14));
    float b = floor(1.0 + sin((x + 1.0) * 3.14));
    float f = fract(x);
    float3 color = phongLightning(normalize(in.worldNormal), in.worldPosition, params, lights, float3(fillY(st, mix(a, b, f), 0.01)));
    return float4(color, 1);
}

