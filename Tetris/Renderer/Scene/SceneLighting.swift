//
//  SceneLighting.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 26.07.2023.
//

import Foundation

struct SceneLighting {
    var lights: [Light]
    
    private static var defaultLight: Light {
        var light = Light()
        light.type = .sun
        light.position = [0.0, 0.0, 0.0]
        light.color = [1.0, 1.0, 1.0]
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1.0, 0.0, 0.0]
        return light
    }
    
    init() {
        var sunlight = Self.defaultLight
        sunlight.position = [1.0, 2.0, -2.0]
        
        var sun2 = Self.defaultLight
        sun2.position = [-1.0, 2.0, 2.0];
        
        var ambientLight = Self.defaultLight
        ambientLight.color = [0.05, 0.1, 0.0]
        ambientLight.type = .ambient
        
        var redLight = Self.defaultLight
        redLight.color = [1.0, 0.0, 0.0]
        redLight.type = .point
        redLight.attenuation = [0.5, 2.0, 1.0]
        redLight.position = [-0.8, 1.76, -0.18]
        
        var spotlight = Self.defaultLight
        spotlight.type = .spot
        spotlight.position = [-0.64, 1.64, -1.07]
        spotlight.color = [1.0, 0.0, 1.0]
        spotlight.attenuation = [1.0, 0.5, 0.0]
        spotlight.coneAngle = Float(40).degreeToRadians
        spotlight.coneDirection = [0.5, -0.7, 1.0]
        spotlight.coneAttenuation = 8
        
        self.lights = [sunlight /*, ambientLight, redLight, spotlight*/]
    }
}
