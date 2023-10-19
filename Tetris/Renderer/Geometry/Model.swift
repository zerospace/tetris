//
//  Model.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 19.07.2023.
//

import MetalKit

enum ModelError: Error {
    case notFound
    case missingMesh
}

class Model: Transformable {
    let mesh: MTKMesh
    let name: String
    var color = NSColor.white {
        didSet {
            let ptr = UnsafeMutableRawPointer(mesh.vertexBuffers[BufferIndex.meshColor.rawValue].buffer.contents()).bindMemory(to: SIMD3<Float>.self, capacity: 1)
            var simd3 = color.simd_float3
            ptr.update(from: &simd3, count: 1)
        }
    }
    var transform = Transform()
    
    var modelMatrix: matrix_float4x4 {
        let translation = float4x4(translation: position)
        let rotation = float4x4(rotation: rotation)
        let scale = float4x4(scaling: scale)
        return translation * rotation * scale
    }
    
    init(name: String, extension ext: String, device: MTLDevice) throws {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw ModelError.notFound
        }
        
        let allocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: url, vertexDescriptor: .defaultDescriptor, bufferAllocator: allocator)
        guard let mdlMesh = asset.childObjects(of: MDLMesh.self).first as? MDLMesh else {
            throw ModelError.missingMesh
        }
        self.name = name
        self.mesh = try MTKMesh(mesh: mdlMesh, device: device)
    }
    
    init(with mdlMesh: MDLMesh, name: String, device: MTLDevice, color: NSColor = .white) throws {
        mdlMesh.vertexDescriptor = .defaultDescriptor
        mdlMesh.vertexBuffers[BufferIndex.meshColor.rawValue] = mdlMesh.allocator.newBuffer(with: color.data, type: .vertex)
        
        self.name = name
        self.mesh = try MTKMesh(mesh: mdlMesh, device: device)
    }
    
    func render(with encoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        var uniforms = uniforms
        uniforms.modelMatrix = modelMatrix
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
        
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: BufferIndex.uniforms.rawValue)
        
        for (index, element) in mesh.vertexDescriptor.layouts.enumerated() {
            guard let layout = element as? MDLVertexBufferLayout else { return }

            if layout.stride != 0 {
                let buffer = mesh.vertexBuffers[index]
                encoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: index)
            }
        }
        
        for submesh in mesh.submeshes {
            encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                          indexCount: submesh.indexCount,
                                          indexType: submesh.indexType,
                                          indexBuffer: submesh.indexBuffer.buffer,
                                          indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
