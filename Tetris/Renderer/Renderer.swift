//
//  Renderer.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 10.05.2023.
//

import Metal
import MetalKit
import simd

let alignedUniformSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100
let alignedParamsSize = (MemoryLayout<Params>.size + 0xFF) & -0x100
let maxBuffers = 3

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    let uniformBuffer: MTLBuffer
    let paramsBuffer: MTLBuffer
    
    private var uniformBufferIndex = 0
    private var uniformBufferOffset = 0
    private var uniforms: UnsafeMutablePointer<Uniforms>
    
    private var paramsBufferIndex = 0
    private var paramsBufferOffset = 0
    private var params: UnsafeMutablePointer<Params>
    
    private let gpuLock = DispatchSemaphore(value: maxBuffers)
    
    
    init(with view: MTKView) throws {
        self.device = view.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let uniformBufferSize = alignedUniformSize * maxBuffers
        self.uniformBuffer = self.device.makeBuffer(length: uniformBufferSize, options: [.storageModeShared])!
        self.uniforms = UnsafeMutableRawPointer(self.uniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)
        
        let paramsBufferSize = alignedParamsSize * maxBuffers
        self.paramsBuffer = self.device.makeBuffer(length: paramsBufferSize, options: [.storageModeShared])!
        self.params = UnsafeMutableRawPointer(self.paramsBuffer.contents()).bindMemory(to: Params.self, capacity: 1)
        
        view.depthStencilPixelFormat = .depth32Float
        
        self.pipelineState = try Renderer.buildRenderPipeline(with: self.device, metalKitView: view, vertexDesc: .defaultDescriptor)
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .less
        depthStateDescriptor.isDepthWriteEnabled = true
        self.depthState = self.device.makeDepthStencilState(descriptor: depthStateDescriptor)!
        
        super.init()
        self.mtkView(view, drawableSizeWillChange: view.bounds.size)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(scene: GameScene, in view: MTKView) {
        _ = gpuLock.wait(timeout: DispatchTime.distantFuture)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.addCompletedHandler { _ in
            self.gpuLock.signal()
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        paramsBufferIndex = (paramsBufferIndex + 1) % maxBuffers
        paramsBufferOffset = alignedParamsSize * paramsBufferIndex
        params = UnsafeMutableRawPointer(paramsBuffer.contents() + paramsBufferOffset).bindMemory(to: Params.self, capacity: 1)
        params[0].lightCount = UInt32(scene.lighting.lights.count)
        params[0].cameraPosition = scene.camera.position
        renderEncoder.setFragmentBuffer(paramsBuffer, offset: paramsBufferOffset, index: BufferIndex.params.rawValue)
        
        var lights = scene.lighting.lights
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: BufferIndex.light.rawValue)
        
        for model in scene.models {
            uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffers
            uniformBufferOffset = alignedUniformSize * uniformBufferIndex
            uniforms = UnsafeMutableRawPointer(uniformBuffer.contents() + uniformBufferOffset).bindMemory(to: Uniforms.self, capacity: 1)
            uniforms[0].projectionMatrix = scene.camera.projectionMatrix
            uniforms[0].viewMatrix = scene.camera.viewMatrix
            
            model.render(with: renderEncoder, uniformBuffer: uniformBuffer, uniformOffset: uniformBufferOffset)
        }
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    class func buildRenderPipeline(with device: MTLDevice, metalKitView: MTKView, vertexDesc: MTLVertexDescriptor) throws -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
        descriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        descriptor.vertexDescriptor = vertexDesc
        
        descriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try device.makeRenderPipelineState(descriptor: descriptor)
    }
}
