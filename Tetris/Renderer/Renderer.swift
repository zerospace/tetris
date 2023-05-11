//
//  Renderer.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 10.05.2023.
//

import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    
    let vertices = [Vertex(color: [1.0, 0.0, 0.0, 1.0], pos: [-1.0, -1.0]),
                    Vertex(color: [0.0, 1.0, 0.0, 1.0], pos: [0.0, 1.0]),
                    Vertex(color: [0.0, 0.0, 1.0, 1.0], pos: [1.0, -1.0])]
    
    init?(with view: MTKView) {
        self.device = view.device!
        self.commandQueue = self.device.makeCommandQueue()!
        self.vertexBuffer = self.device.makeBuffer(bytes: self.vertices, length: self.vertices.count * MemoryLayout<Vertex>.stride)!
        
        do {
            self.pipelineState = try Renderer.buildRenderPipeline(with: self.device, metalKitView: view)
        }
        catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //
    }
    
    class func buildRenderPipeline(with device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
        descriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        descriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: descriptor)
    }
}
