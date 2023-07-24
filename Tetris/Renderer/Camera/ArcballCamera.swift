//
//  ArcballCamera.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 24.07.2023.
//

import Foundation

struct ArcballCamera: Camera {
    var transform = Transform()
    
    var aspect: Float = 1.0
    var fov = Float(70.0).degreeToRadians
    var near: Float = 0.1
    var far: Float = 100.0
    
    var projectionMatrix: float4x4 {
        float4x4(fovyRadians: fov, nearZ: near, farZ: far, aspectRatio: aspect)
    }
    
    let minDistance: Float = 0.0
    let maxDistance: Float = 20.0
    var target: SIMD3<Float> = [0.0, 0.0, 0.0]
    var distance: Float = 2.5
    
    var viewMatrix: float4x4 {
        if target == position {
            return (float4x4(translation: target) * float4x4(rotation: rotation)).inverse
        }
        return float4x4(eye: position, center: target, up: [0.0, 1.0, 0.0])
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    mutating func update(deltaTime: Float) {
        distance -= (InputController.shared.mouseScroll.x + InputController.shared.mouseScroll.y) * MovementSettings.scrollSensitivity
        distance = min(maxDistance, distance)
        distance = max(minDistance, distance)
        InputController.shared.mouseScroll = .zero
        if InputController.shared.leftMouseDown {
            rotation.x += InputController.shared.mouseDelta.y * MovementSettings.panSensitivity
            rotation.y += InputController.shared.mouseDelta.x * MovementSettings.panSensitivity
            rotation.x = max(-.pi/2.0, min(rotation.x, .pi/2.0))
            InputController.shared.mouseDelta = .zero
        }
        let rotateMatrix = float4x4(rotation: [-rotation.x, rotation.y, 0.0])
        let distanceVector = SIMD4<Float>(0.0, 0.0, -distance, 0.0)
        let rotatedVector = rotateMatrix * distanceVector
        position = target + rotatedVector.xyz
    }
}
