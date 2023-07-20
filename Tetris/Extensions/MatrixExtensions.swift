//
//  MatrixExtensions.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 19.05.2023.
//

import simd

extension float4x4 {
    static var identity: float4x4 { matrix_identity_float4x4 }
    
    // MARK: - Translation
    init(translation t: SIMD3<Float>) {
        self = float4x4([1.0, 0.0, 0.0, 0.0],
                        [0.0, 1.0, 0.0, 0.0],
                        [0.0, 0.0, 1.0, 0.0],
                        [t.x, t.y, t.z, 1.0])
    }
    
    // MARK: - Scaling
    init(scaling s: SIMD3<Float>) {
        self = float4x4([s.x, 0.0, 0.0, 0.0],
                        [0.0, s.y, 0.0, 0.0],
                        [0.0, 0.0, s.z, 0.0],
                        [0.0, 0.0, 0.0, 1.0])
    }
    
    init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1.0 / scaling
    }
    
    // MARK: - Rotation
    init(rotationX angle: Float) {
        self = float4x4([1.0, 0.0, 0.0, 0.0],
                        [0.0, cosf(angle), sinf(angle), 0.0],
                        [0.0, -sinf(angle), cosf(angle), 0.0],
                        [0.0, 0.0, 0.0, 1.0])
    }
    
    init(rotationY angle: Float) {
        self = float4x4([cosf(angle), 0.0, -sinf(angle), 0.0],
                        [0.0, 1.0, 0.0, 0.0],
                        [sinf(angle), 0.0, cosf(angle), 0.0],
                        [0.0, 0.0, 0.0, 1.0])
    }
    
    init(rotationZ angle: Float) {
        self = float4x4([cosf(angle), sinf(angle), 0.0, 0.0],
                        [-sinf(angle), cosf(angle), 0.0, 0.0],
                        [0.0, 0.0, 1.0, 0.0],
                        [0.0, 0.0, 0.0, 1.0])
    }
    
    init(rotation angle: SIMD3<Float>) {
        self = float4x4(rotationX: angle.x) * float4x4(rotationY: angle.y) * float4x4(rotationZ: angle.z)
    }
    
    // MARK: - Projection matrix
    init(fovyRadians fov: Float, nearZ: Float, farZ: Float, aspectRatio: Float, lhs: Bool = true) {
        let y = 1.0 / tanf(fov * 0.5)
        let x = y / aspectRatio
        let z = lhs ? farZ / (farZ - nearZ) : farZ / (nearZ - farZ)
        self = float4x4([x, 0.0, 0.0, 0.0],
                        [0.0, y, 0.0, 0.0],
                        [0.0, 0.0, z, (lhs ? 1 : -1)],
                        [0.0, 0.0, z * (lhs ? -nearZ : nearZ), 0.0])
    }
    
    init(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) {
        let z = normalize(center - eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        
        self = float4x4([x.x, y.x, z.x, 0.0],
                        [x.y, y.y, z.y, 0.0],
                        [x.z, y.z, z.z, 0.0],
                        [-dot(x, eye), -dot(y, eye), -dot(z, eye), 0.0])
    }
    
    // MARK: - Orthographic matrix
    init(orthographic rect: CGRect, nearZ: Float, farZ: Float) {
        let left = Float(rect.origin.x)
        let right = Float(rect.origin.x + rect.size.width)
        let top = Float(rect.origin.y)
        let bottom = Float(rect.origin.y - rect.size.height)
        self = float4x4([2.0/(right - left), 0.0, 0.0, 0.0],
                        [0.0, 2.0/(top - bottom), 0.0, 0.0],
                        [0.0, 0.0, 1.0/(farZ - nearZ), 0.0],
                        [(left + right)/(left - right), (top + bottom)/(bottom - top), nearZ/(nearZ - farZ), 1.0])
    }
}
