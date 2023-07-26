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
        sunlight.position = [0.0, 2.0, -2.0]
        
        self.lights = [sunlight]
    }
}
