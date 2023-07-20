//
//  Camera.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import MetalKit

protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}
