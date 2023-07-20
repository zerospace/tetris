//
//  Transform.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import Foundation

struct Transform {
    var position: SIMD3<Float> = [0.0, 0.0, 0.0]
    var rotation: SIMD3<Float> = [0.0, 0.0, 0.0]
    var scale: Float = 1.0
}

protocol Transformable {
    var transform: Transform { get set }
}

extension Transformable {
    var position: SIMD3<Float> {
        get { return transform.position }
        set { transform.position = newValue }
    }
    
    var rotation: SIMD3<Float> {
        get { return transform.rotation }
        set { transform.rotation = newValue }
    }
    
    var scale: Float {
        get { return transform.scale }
        set { transform.scale = newValue }
    }
}
