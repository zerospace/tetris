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
    
    float materialShininess = 32.0;
    float3 materialSpecularColor = float3(1.0, 1.0, 1.0);
    
    for(uint i = 0; i < params.lightCount; i++) {
        Light light = lights[i];
        switch (light.type) {
            case LightTypeSun: {
                float3 lightDirection = normalize(-light.position);
                float diffuseIntensity = saturate(-dot(lightDirection, normal));
                diffuse += light.color * baseColor * diffuseIntensity;
                
                if (diffuseIntensity > 0) {
                    float3 reflection = reflect(lightDirection, normal);
                    float3 viewDirection = normalize(params.cameraPosition);
                    float3 specularIntensity = pow(saturate(dot(reflection, viewDirection)), materialShininess);
                    specular += light.specularColor * materialSpecularColor * specularIntensity;
                }
                
                break;
            }
            case LightTypePoint: {
                float dist = distance(light.position, position);
                float3 lightDirection = normalize(light.position - position);
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * dist + light.attenuation.z * dist * dist);
                float diffuseIntensity = saturate(dot(lightDirection, normal));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuse += color;
                break;
            }
            case LightTypeSpot: {
                float dist = distance(light.position, position);
                float3 lightDirection = normalize(light.position - position);
                float3 coneDirection = normalize(light.coneDirection);
                float spotResult = dot(lightDirection, -coneDirection);
                if (spotResult > cos(light.coneAngle)) {
                    float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * dist + light.attenuation.z * dist * dist);
                    attenuation *= pow(spotResult, light.coneAttenuation);
                    float diffuseIntensity = saturate(dot(lightDirection, normal));
                    float3 color = light.color * baseColor * diffuseIntensity;
                    color *= attenuation;
                    diffuse += color;
                }
                break;
            }
            case LightTypeAmbient: {
                ambient += light.color;
                break;
            }
            case LightTypeUnused: {
                break;
            }
        }
    }
    
    return diffuse + specular + ambient;
}
