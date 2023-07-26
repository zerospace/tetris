//
//  Lighting.metal
//  Tetris
//
//  Created by Oleksandr Fedko on 26.07.2023.
//

#include <metal_stdlib>

using namespace metal;

#import "Lighting.h"

float3 phongLightning(float3 normal,
                      float3 position,
                      constant Params &params,
                      constant Light *lights,
                      float3 baseColor)
{
    float3 diffuse = 0;
    float3 ambient = 0;
    float3 specular = 0;
    
    for(uint i = 0; i < params.lightCount; i++) {
        Light light = lights[i];
        switch (light.type) {
            case LightTypeSun: {
                float3 lightDirection = normalize(-light.position);
                float diffuseIntensity = saturate(-dot(lightDirection, normal));
                diffuse += light.color * baseColor * diffuseIntensity;
                break;
            }
            case LightTypePoint: {
                break;
            }
            case LightTypeSpot: {
                break;
            }
            case LightTypeAmbient: {
                break;
            }
            case LightTypeUnused: {
                break;
            }
        }
    }
    
    return diffuse + specular + ambient;
}
