//
//  OrthographicCamera.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 24.07.2023.
//

import Foundation

struct OrthographicCamera: Camera, Movement {
    var input: InputController
    var transform = Transform()
    
    var aspect: CGFloat = 1.0
    var viewSize: CGFloat = 10.0
    var near: Float = 0.1
    var far: Float = 100.0
    
    var projectionMatrix: float4x4 {
        let rect = CGRect(x: -viewSize * aspect * 0.5, y: viewSize * 0.5, width: viewSize * aspect, height: viewSize)
        return float4x4(orthographic: rect, nearZ: near, farZ: far)
    }
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
    }
    
    mutating func update(size: CGSize) {
        aspect = size.width / size.height
    }
    
    mutating func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        position += transform.position
        viewSize -= CGFloat(input.mouseScroll.x + input.mouseScroll.y)
        input.mouseScroll = .zero
    }
}
