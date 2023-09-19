//
//  Movement.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 24.07.2023.
//

import Foundation

protocol Movement where Self: Transformable {
    var input: InputController { get set }
}

extension Movement {
    var forwardVector: SIMD3<Float> { normalize([sin(rotation.y), 0.0, cos(rotation.y)]) }
    var rightVector: SIMD3<Float> { [forwardVector.z, forwardVector.y, -forwardVector.x] }
    
    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
//        let rotation = deltaTime * input.settings.rotationSpeed
//        if input.keyPressed.contains(.leftArrow) {
//            transform.rotation.y -= rotation
//        }
//        if input.keyPressed.contains(.rightArrow) {
//            transform.rotation.y += rotation
//        }
        
        var direction: SIMD3<Float> = .zero
        if input.keyPressed.contains(.keyW) {
            direction.z += 1
        }
        if input.keyPressed.contains(.keyS) {
            direction.z -= 1
        }
        if input.keyPressed.contains(.keyA) {
            direction.x -= 1
        }
        if input.keyPressed.contains(.keyD) {
            direction.x += 1
        }
        let translation = deltaTime * input.settings.translationSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += (direction.z * forwardVector + direction.x * rightVector) * translation
        }
        
        return transform
    }
}
