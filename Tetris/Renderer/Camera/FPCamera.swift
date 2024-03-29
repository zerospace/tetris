//
//  FPCamera.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import Foundation

struct FPCamera: Camera, Movement {
    var input: InputController
    var transform = Transform()
    
    var aspect: Float = 1.0
    var fov = Float(70.0).degreeToRadians
    var near: Float = 0.1
    var far: Float = 100.0
    
    var projectionMatrix: float4x4 {
        float4x4(fovyRadians: fov, nearZ: near, farZ: far, aspectRatio: aspect)
    }
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    mutating func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        position += transform.position
        
//        if input.leftMouseDown {
//            rotation.x += input.mouseDelta.y * input.settings.panSensitivity
//            rotation.y += input.mouseDelta.x * input.settings.panSensitivity
//            rotation.x = max(-.pi/2.0, min(rotation.x, .pi/2.0))
//            input.mouseDelta = .zero
//        }
    }
}
