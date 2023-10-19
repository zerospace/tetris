//
//  Vertex.h
//  Tetris
//
//  Created by Oleksandr Fedko on 17.10.2023.
//

#ifndef Vertex_h
#define Vertex_h

typedef struct {
    float3 position [[attribute(VertexAttributePosition)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
    float3 color [[attribute(VertexAttributeColor)]];
    float2 uv [[attribute(VertexAttributeUV)]];
} Vertex;

typedef struct {
    float4 position [[position]];
    float3 normal;
    float2 uv;
    float3 color;
    float3 worldPosition;
    float3 worldNormal;
} VertexOut;

#endif /* Vertex_h */
