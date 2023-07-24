//
//  GameScene.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import MetalKit

struct GameScene {
    let models: [Model]
    
    var camera: ArcballCamera
    
    private var venus: Model
    private var ground: Model
    
    init(device: MTLDevice) throws {
        self.venus = try Model(name: "Venus_de_Milo", extension: "obj", device: device)
        self.venus.position.y = 0.5
        self.venus.scale = 0.001
        
        let plane = MDLMesh.newPlane(withDimensions: [1.0, 1.0], segments: [1, 1], geometryType: .triangles, allocator: MTKMeshBufferAllocator(device: device))
        self.ground = try Model(with: plane, name: "ground", device: device)
        self.ground.position.y = 0.5
        self.ground.scale = 10.0
        
        self.models = [self.venus, self.ground]
        
//        self.camera = FPCamera()
//        self.camera.position = [0.0, 1.5, -5.0]
        
        self.camera = ArcballCamera()
        self.camera.distance = length(self.camera.position)
        self.camera.target = [0.0, 1.2, 0.0]
    }
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    mutating func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
    }
}
