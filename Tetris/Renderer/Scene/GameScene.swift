//
//  GameScene.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 20.07.2023.
//

import MetalKit

struct GameScene {
    let models: [Model]
    
    var camera: FPCamera
    let lighting: SceneLighting
    let input: InputController
    
    private var venus: Model
    private var ground: Model
    
    init(device: MTLDevice, input: InputController) throws {
        self.input = input
        self.lighting = SceneLighting()
        
        self.venus = try Model(name: "monkey", extension: "obj", device: device)
        self.venus.position.y = 1.0
        self.venus.rotation.y = Float(180).degreeToRadians
//        self.venus.scale = 0.001
        
        let plane = MDLMesh.newPlane(withDimensions: [1.0, 1.0], segments: [1, 1], geometryType: .triangles, allocator: MTKMeshBufferAllocator(device: device))
        self.ground = try Model(with: plane, name: "ground", device: device)
        self.ground.position.y = 0.5
        self.ground.scale = 10.0
        
        self.models = [self.venus, self.ground]
        
        self.camera = FPCamera(input: self.input)
        self.camera.position = [0.0, 1.5, -5.0]
        
//        self.camera = ArcballCamera()
//        self.camera.distance = length(self.camera.position)
//        self.camera.target = [0.0, 1.2, 0.0]
        
//        self.camera = OrthographicCamera()
//        self.camera.position = [3.0, 2.0, 0.0]
//        self.camera.rotation.y = -.pi / 2.0
    }
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    mutating func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
    }
}
