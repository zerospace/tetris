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
let maxBuffers = 3

enum RendererError: Error {
    case badVertexDescriptor
    case cantLoadModel
    case noMeshAvailable
}

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    let uniformBuffer: MTLBuffer
//    let colorBuffer: MTLBuffer
    
    private(set) var scene: GameScene
    
    private var uniformBufferOffset = 0
    private var uniformBufferIndex = 0
    private var uniforms: UnsafeMutablePointer<Uniforms>
    private var rotation: Float = 0
    
    private let gpuLock = DispatchSemaphore(value: maxBuffers)
    private var lastRenderTime: CFTimeInterval? = nil
    private var currentTime = 0.0
    
    
    init(with view: MTKView) throws {
        self.device = view.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        let uniformBufferSize = alignedUniformSize * maxBuffers
        self.uniformBuffer = self.device.makeBuffer(length: uniformBufferSize, options: [.storageModeShared])!
        self.uniforms = UnsafeMutableRawPointer(self.uniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)
        
        view.depthStencilPixelFormat = .depth32Float
        
        self.pipelineState = try Renderer.buildRenderPipeline(with: self.device, metalKitView: view, vertexDesc: .defaultDescriptor)
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .less
        depthStateDescriptor.isDepthWriteEnabled = true
        self.depthState = self.device.makeDepthStencilState(descriptor: depthStateDescriptor)!
        
        self.scene = try GameScene(device: self.device)
        
        super.init()
        self.mtkView(view, drawableSizeWillChange: view.bounds.size)
    }
    
    func draw(in view: MTKView) {
        _ = gpuLock.wait(timeout: DispatchTime.distantFuture)

        let systemTime = CACurrentMediaTime()
        let timeDiff = lastRenderTime == nil ? 0 : systemTime - lastRenderTime!
        lastRenderTime = systemTime
        
        rotation += Float(timeDiff)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.addCompletedHandler { _ in
            self.gpuLock.signal()
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        scene.update(deltaTime: rotation)
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
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.update(size: size)
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
