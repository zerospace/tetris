//
//  UIColorExtensions.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 18.09.2023.
//

import Cocoa

extension NSColor {
    var data: Data {
        guard let rgb = usingColorSpace(.deviceRGB) else { return Data() }
        var simd = self.simd_float3
        return Data(bytes: &simd, count: MemoryLayout<SIMD3<Float>>.stride)
    }
    
    var simd_float3: SIMD3<Float> {
        guard let rgb = usingColorSpace(.deviceRGB) else { return SIMD3<Float>(0.0, 0.0, 0.0) }
        return SIMD3<Float>([Float(rgb.redComponent), Float(rgb.greenComponent), Float(rgb.blueComponent)])
    }
}
