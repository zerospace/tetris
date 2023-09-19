//
//  Renderer.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 10.05.2023.
//

import Metal
import MetalKit
import simd

let maxBuffers = 3

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    let colorBuffer: MTLBuffer
    
    private var uniformBufferIndex = 0
    private var uniforms = Uniforms()
    
    private var params = Params()
    
    private let gpuLock = DispatchSemaphore(value: maxBuffers)
    
    
    init(with view: MTKView) throws {
        self.device = view.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        self.colorBuffer = device.makeBuffer(length: MemoryLayout<simd_float3>.stride, options: [.storageModeShared])!
        
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
        _ = gpuLock.wait(timeout: .distantFuture)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.addCompletedHandler { _ in
            self.gpuLock.signal()
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        params.lightCount = UInt32(scene.lighting.lights.count)
        params.cameraPosition = scene.camera.position
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: BufferIndex.params.rawValue)
        
        var lights = scene.lighting.lights
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: BufferIndex.light.rawValue)
        
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffers
        
        
        for model in scene.models {
            model.render(with: renderEncoder, uniforms: uniforms)
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
