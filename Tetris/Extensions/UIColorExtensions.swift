//
//  UIColorExtensions.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 18.09.2023.
//

import Cocoa

extension NSColor {
    func data(count: Int) -> Data? {
        guard let rgb = usingColorSpace(.deviceRGB) else { return nil }
        var array = Array(repeating: SIMD3<Float>([Float(rgb.redComponent), Float(rgb.greenComponent), Float(rgb.blueComponent)]), count: count)
        return Data(bytes: &array, count: MemoryLayout<simd_float3>.stride * count)
    }
}
