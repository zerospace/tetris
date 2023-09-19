//
//  GameScene.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import MetalKit

struct GameScene {
    var models: [Model] {
        return sceneModels + tetramino + blocks.flatMap({ $0 }).compactMap({ $0 })
    }
    
    var camera: FPCamera
    let lighting: SceneLighting
    let input: InputController
    private let device: MTLDevice
    private let allocator: MDLMeshBufferAllocator
    
    private var sceneModels = [Model]()
    private var ground: Model
    private var plinth: Model
    private var blocks: [[Model?]] = Array(repeating: Array(repeating: nil, count: kFieldWidth), count: kFieldHeight)
    private var tetramino = [Model]()
    
    init(device: MTLDevice, input: InputController) throws {
        self.device = device
        self.input = input
        self.lighting = SceneLighting()
        self.allocator = MTKMeshBufferAllocator(device: device)
        
//        self.venus = try Model(name: "monkey", extension: "obj", device: device)
//        self.venus.position.y = 1.0
//        self.venus.rotation.y = Float(180).degreeToRadians
        
        let plane = MDLMesh.newPlane(withDimensions: [100.0, 100.0], segments: [10, 10], geometryType: .triangles, allocator: self.allocator)
        self.ground = try Model(with: plane, name: "ground", device: device, color: NSColor(red: 0.3, green: 0.5, blue: 0.1, alpha: 1.0))
        self.ground.position = .zero
        
        let block = MDLMesh.newBox(withDimensions: [Float(kFieldWidth), 1.0, 1.0], segments: [UInt32(kFieldWidth), 1, 1], geometryType: .triangles, inwardNormals: false, allocator: self.allocator)
        self.plinth = try Model(with: block, name: "plinth", device: device, color: NSColor(red: 0.25, green: 0.1, blue: 0.0, alpha: 1.0))
//        self.plinth.rotation.y = Float(-25).degreeToRadians
        
        sceneModels = [self.ground, self.plinth]
        
        for _ in 0..<4 {
            let mesh = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
            let block = try Model(with: mesh, name: "block", device: device)
            tetramino.append(block)
        }
        
        self.camera = FPCamera(input: self.input)
        self.camera.position = [0.0, 10.0, -20.0]
    }
    
    mutating func addBlock(_ coord: SIMD2<Int>) {
        let mesh = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        if let block = try? Model(with: mesh, name: "block", device: device) {
            blocks[coord.x][coord.y] = block
        }
    }
    
    mutating func rearangeBlocks(_ vec: SIMD3<Int>) {
        blocks[vec.z][vec.y] = blocks[vec.x][vec.y]
    }
    
    mutating func updateBlocks(tetramino gameCoord: [SIMD2<Int>]) {
        for i in 0..<gameCoord.count {
            tetramino[i].position = gameCoordinatesToPosition(gameCoord[i])
            tetramino[i].rotation = plinth.rotation
            tetramino[i].scale = plinth.scale
        }
        
        for i in 0..<kFieldWidth {
            for j in 0..<kFieldHeight {
                if var model = blocks[j][i] {
                    model.position = gameCoordinatesToPosition([i, j])
                    model.rotation = plinth.rotation
                    model.scale = plinth.scale
                }
            }
        }
    }
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    mutating func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
    }
    
    // MARK: - Private
    private func gameCoordinatesToPosition(_ coordinates: SIMD2<Int>) -> SIMD3<Float> {
        return (plinth.modelMatrix * float4x4(translation: [Float(coordinates.x) - (Float(kFieldWidth / 2) - 0.5), Float(kFieldHeight) - Float(coordinates.y), 0])).columns.3.xyz
    }
}
