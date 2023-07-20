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
    BufferIndexUniforms         = 2,
//    BufferIndexParams           = 3
};

typedef NS_ENUM(EnumType, VertexAttribute) {
    VertexAttributePosition     = 0,
    VertexAttributeNormal       = 1
};

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    uint width;
    uint height;
    uint tiling;
} Params;

#endif /* ShaderTypes_h */
