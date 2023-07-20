//
//  FloatExtension.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 19.05.2023.
//

import Foundation

extension Float {
    var radiansToDegree: Float { (self / .pi) * 180.0 }
    var degreeToRadians: Float { (self / 180.0) * .pi }
}
