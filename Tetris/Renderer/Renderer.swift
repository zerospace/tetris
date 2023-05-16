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
//    let vertexBuffer: MTLBuffer
    let fragmentUniformsBuffer: MTLBuffer
    
    let vertices = [Vertex(color: [1.0, 0.0, 0.0, 1.0], pos: [-1.0, -1.0]),
                    Vertex(color: [0.0, 1.0, 0.0, 1.0], pos: [0.0, 1.0]),
                    Vertex(color: [0.0, 0.0, 1.0, 1.0], pos: [1.0, -1.0])]
    
    let meshAllocator: MTKMeshBufferAllocator
    let mdlMesh: MDLMesh
    let cubeMesh: MTKMesh
    
    private let gpuLock = DispatchSemaphore(value: 1)
    private(set) var lastRenderTime: CFTimeInterval? = nil
    private(set) var currentTime = 0.0
    
    init?(with view: MTKView) {
        self.device = view.device!
        self.commandQueue = self.device.makeCommandQueue()!
//        self.vertexBuffer = self.device.makeBuffer(bytes: self.vertices, length: self.vertices.count * MemoryLayout<Vertex>.stride)!
        
        self.meshAllocator = MTKMeshBufferAllocator(device: self.device)
//        self.mdlMesh = MDLMesh(boxWithExtent: [0.75, 0.75, 0.75], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: self.meshAllocator)
        self.mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75], segments: [50, 50], inwardNormals: false, geometryType: .triangles, allocator: self.meshAllocator)
        
        var initialFragmentUniforms = FragmentUniforms(brightness: 1.0)
        self.fragmentUniformsBuffer = self.device.makeBuffer(bytes: &initialFragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride)!
        
        do {
            self.cubeMesh = try MTKMesh(mesh: self.mdlMesh, device: self.device)
            self.pipelineState = try Renderer.buildRenderPipeline(with: self.device, metalKitView: view, vertexDesc: self.cubeMesh.vertexDescriptor)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func draw(in view: MTKView) {
        gpuLock.wait()

        let systemTime = CACurrentMediaTime()
        let timeDiff = lastRenderTime == nil ? 0 : systemTime - lastRenderTime!
        lastRenderTime = systemTime

        update(deltaTime: timeDiff)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.addCompletedHandler { _ in
            self.gpuLock.signal()
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(cubeMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.drawIndexedPrimitives(type: .line, indexCount: cubeMesh.submeshes[0].indexCount, indexType: cubeMesh.submeshes[0].indexType, indexBuffer: cubeMesh.submeshes[0].indexBuffer.buffer, indexBufferOffset: 0)
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //
    }
    
    class func buildRenderPipeline(with device: MTLDevice, metalKitView: MTKView, vertexDesc: MDLVertexDescriptor) throws -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
//        descriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
//        descriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        descriptor.vertexFunction = library?.makeFunction(name: "vertexCube")
        descriptor.fragmentFunction = library?.makeFunction(name: "fragmentCube")
        
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDesc)
        
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm //metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    private func update(deltaTime: CFTimeInterval) {
        let ptr = fragmentUniformsBuffer.contents().bindMemory(to: FragmentUniforms.self, capacity: 1)
        ptr.pointee.brightness = Float(0.5 * cos(currentTime) + 0.5)
        
//        let vPtr = vertexBuffer.contents().bindMemory(to: Vertex.self, capacity: vertices.count)
//        for i in 0..<vertices.count {
//            let origin = vPtr[i].pos
//            let angle = Float(1.0 / 180.0) * .pi
//            vPtr[i].pos.x = Float((origin.x * cos(angle)) - (origin.y * sin(angle)))
//            vPtr[i].pos.y = Float((origin.y * cos(angle)) + (origin.x * sin(angle)))
//        }
        
        currentTime += deltaTime
    }
}
