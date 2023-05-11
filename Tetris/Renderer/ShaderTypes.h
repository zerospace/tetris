//
//  ShaderTypes.h
//  Tetris
//
//  Created by Oleksandr Fedko on 11.05.2023.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#import <simd/simd.h>

struct Vertex {
    vector_float4 color;
    vector_float2 pos;
};

#endif /* ShaderTypes_h */
