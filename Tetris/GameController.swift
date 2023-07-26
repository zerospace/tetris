//
//  GameController.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 26.07.2023.
//

import MetalKit

class GameController: NSObject, MTKViewDelegate {
    let renderer: Renderer
    private(set) var scene: GameScene
    let input: InputController
    private(set) var fps: Double = 0.0
    
    private var lastRenderTime = CACurrentMediaTime()
    
    init(metalView: MTKView) throws {
        self.input = InputController()
        self.renderer = try Renderer(with: metalView)
        self.scene = try GameScene(device: self.renderer.device, input: self.input)
        super.init()
        metalView.delegate = self
        self.fps = Double(metalView.preferredFramesPerSecond)
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
    
    // MARK: - MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.update(size: size)
        renderer.mtkView(view, drawableSizeWillChange: size)
    }
    
    func draw(in view: MTKView) {
        let systemTime = CACurrentMediaTime()
        let timeDiff = Float(systemTime - lastRenderTime)
        lastRenderTime = systemTime
        scene.update(deltaTime: timeDiff)
        renderer.draw(scene: scene, in: view)
    }
}
