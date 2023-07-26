//
//  Lighting.h
//  Tetris
//
//  Created by Oleksandr Fedko on 26.07.2023.
//

#ifndef Lighting_h
#define Lighting_h

#import "ShaderTypes.h"

float3 phongLightning(float3 normal,
                      float3 position,
                      constant Params &params,
                      constant Light *lights,
                      float3 baseColor);

#endif /* Lighting_h */
