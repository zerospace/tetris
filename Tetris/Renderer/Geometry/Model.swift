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
    
    init(with mdlMesh: MDLMesh, name: String, device: MTLDevice) throws {
        mdlMesh.vertexDescriptor = .defaultDescriptor
        self.name = name
        self.mesh = try MTKMesh(mesh: mdlMesh, device: device)
    }
    
    func render(with encoder: MTLRenderCommandEncoder, uniformBuffer: MTLBuffer, uniformOffset: Int/*, params: inout Params*/) {
        let uniforms = UnsafeMutableRawPointer(uniformBuffer.contents() + uniformOffset).bindMemory(to: Uniforms.self, capacity: 1)
        uniforms.pointee.modelMatrix = modelMatrix
        uniforms.pointee.normalMatrix = uniforms.pointee.modelMatrix.upperLeft
        
        encoder.setVertexBuffer(uniformBuffer, offset: uniformOffset, index: BufferIndex.uniforms.rawValue)
        
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
