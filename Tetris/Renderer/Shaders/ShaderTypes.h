//
//  ShaderTypes.h
//  Tetris
//
//  Created by Oleksandr Fedko on 11.05.2023.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t EnumType;
#else
#import <Foundation/Foundation.h>
typedef NSInteger EnumType;
#endif

#import <simd/simd.h>

typedef NS_ENUM(EnumType, BufferIndex) {
    BufferIndexMeshPositions    = 0,
    BufferIndexMeshNormal       = 1,
    BufferIndexMeshColor        = 2,
    BufferIndexMeshUV           = 3,
    BufferIndexUniforms         = 4,
    BufferIndexParams           = 5,
    BufferIndexLight            = 6
};

typedef NS_ENUM(EnumType, VertexAttribute) {
    VertexAttributePosition     = 0,
    VertexAttributeNormal       = 1,
    VertexAttributeColor        = 2,
    VertexAttributeUV           = 3
};

typedef NS_ENUM(EnumType, LightType) {
    LightTypeUnused             = 0,
    LightTypeSun                = 1,
    LightTypeSpot               = 2,
    LightTypePoint              = 3,
    LightTypeAmbient            = 4
};

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef struct {
    uint width;
    uint height;
    uint tiling;
    uint lightCount;
    vector_float3 cameraPosition;
} Params;

typedef struct {
    LightType type;
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float radius;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

#endif /* ShaderTypes_h */
