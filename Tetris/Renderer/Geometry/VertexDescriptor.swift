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
        
        // MARK: Attributes
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshNormal.rawValue
        
        mtlVertexDescriptor.attributes[VertexAttribute.color.rawValue].format = .float3
        mtlVertexDescriptor.attributes[VertexAttribute.color.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.color.rawValue].bufferIndex = BufferIndex.meshColor.rawValue
        
        mtlVertexDescriptor.attributes[VertexAttribute.UV.rawValue].format = .float2
        mtlVertexDescriptor.attributes[VertexAttribute.UV.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.UV.rawValue].bufferIndex = BufferIndex.meshUV.rawValue
        
        // MARK: Layouts
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<simd_float3>.stride
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = .perVertex
        
        mtlVertexDescriptor.layouts[BufferIndex.meshNormal.rawValue].stride = MemoryLayout<simd_float3>.stride
        mtlVertexDescriptor.layouts[BufferIndex.meshNormal.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshNormal.rawValue].stepFunction = .perVertex
        
        mtlVertexDescriptor.layouts[BufferIndex.meshColor.rawValue].stride = MemoryLayout<simd_float3>.stride
        mtlVertexDescriptor.layouts[BufferIndex.meshColor.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshColor.rawValue].stepFunction = .perVertex
        
        mtlVertexDescriptor.layouts[BufferIndex.meshUV.rawValue].stride = MemoryLayout<simd_float2>.stride
        mtlVertexDescriptor.layouts[BufferIndex.meshUV.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshUV.rawValue].stepFunction = .perVertex

        return mtlVertexDescriptor
    }
}

extension MDLVertexDescriptor {
    static var defaultDescriptor: MDLVertexDescriptor {
        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultDescriptor)
        if let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] {
            attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
            attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal
            attributes[VertexAttribute.color.rawValue].name = MDLVertexAttributeColor
            attributes[VertexAttribute.UV.rawValue].name = MDLVertexAttributeTextureCoordinate
        }
        return mdlVertexDescriptor
    }
}
