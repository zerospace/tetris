//
//  Movement.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 24.07.2023.
//

import Foundation

struct MovementSettings {
    static var rotationSpeed: Float { 2.0 }
    static var translationSpeed: Float { 3.0 }
    static var scrollSensitivity: Float { 0.1 }
    static var panSensitivity: Float { 0.008 }
}

protocol Movement where Self: Transformable { }

extension Movement {
    var forwardVector: SIMD3<Float> { normalize([sin(rotation.y), 0.0, cos(rotation.y)]) }
    var rightVector: SIMD3<Float> { [forwardVector.z, forwardVector.y, -forwardVector.x] }
    
    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
        let rotation = deltaTime * MovementSettings.rotationSpeed
        if InputController.shared.keyPressed.contains(.leftArrow) {
            transform.rotation.y -= rotation
        }
        if InputController.shared.keyPressed.contains(.rightArrow) {
            transform.rotation.y += rotation
        }
        
        var direction: SIMD3<Float> = .zero
        if InputController.shared.keyPressed.contains(.keyW) {
            direction.z += 1
        }
        if InputController.shared.keyPressed.contains(.keyS) {
            direction.z -= 1
        }
        if InputController.shared.keyPressed.contains(.keyA) {
            direction.x -= 1
        }
        if InputController.shared.keyPressed.contains(.keyD) {
            direction.x += 1
        }
        let translation = deltaTime * MovementSettings.translationSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += (direction.z * forwardVector + direction.x * rightVector) * translation
        }
        
        return transform
    }
}
