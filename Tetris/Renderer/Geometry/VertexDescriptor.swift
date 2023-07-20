//
//  VertexDescriptor.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultDescriptor: MTLVertexDescriptor {
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshNormal.rawValue
        
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<simd_float3>.stride
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = .perVertex
        
        mtlVertexDescriptor.layouts[BufferIndex.meshNormal.rawValue].stride = MemoryLayout<simd_float3>.stride
        mtlVertexDescriptor.layouts[BufferIndex.meshNormal.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshNormal.rawValue].stepFunction = .perVertex

        return mtlVertexDescriptor
    }
}

extension MDLVertexDescriptor {
    static var defaultDescriptor: MDLVertexDescriptor {
        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultDescriptor)
        if let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] {
            attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
            attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal
        }
        return mdlVertexDescriptor
    }
}
