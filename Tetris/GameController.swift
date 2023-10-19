//
//  GameController.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 26.07.2023.
//

import MetalKit
import Combine
import GameController

let kFieldWidth = 10
let kFieldHeight = 20

class GameController: NSObject, MTKViewDelegate {
    let renderer: Renderer
    private(set) var scene: GameScene
    let input: InputController
    private(set) var fps: Double = 0.0
    
    private var field = Array(repeating: Array(repeating: 0, count: kFieldWidth), count: kFieldHeight)
    private var currTetraminoPos = Array(repeating: SIMD2<Int>.zero, count: 4)
    private var prevTetraminoPos = Array(repeating: SIMD2<Int>.zero, count: 4)
    
    private let blocks = [[1, 3, 5, 7], // I
                          [2, 4, 5, 7], // Z
                          [3, 5, 4, 6], // S
                          [3, 5, 4, 7], // T
                          [2, 3, 5, 7], // L
                          [3, 5, 7, 6], // J
                          [2, 3, 4, 5]] // O
    
    private let colors: [NSColor] = [.cyan,     // I
                                     .red,      // Z
                                     .green,    // S
                                     .purple,   // T
                                     .orange,   // L
                                     .blue,     // J
                                     .yellow]   // O
    private var currentColor = NSColor.white
    
    private var lastRenderTime = CACurrentMediaTime()
    private var gameTimer: Float = 0
    private var gameDelay: Float = 0.3
    private var inputTimer: Float = 0
    private var inputDelay: Float = 0.1
    
    private var dx = 0
    private var rotate = false
    
    init(metalView: MTKView) throws {
        self.input = InputController()
        self.renderer = try Renderer(with: metalView)
        self.scene = try GameScene(device: self.renderer.device, input: self.input)
        super.init()
        metalView.delegate = self
        self.fps = Double(metalView.preferredFramesPerSecond)
        
        newTetramino()
        
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
        
        gameTimer += timeDiff
            
        updateGameState(deltaTime: timeDiff)
        scene.updateBlocks(tetramino: currTetraminoPos, with: currentColor)
        scene.update(deltaTime: timeDiff)
        renderer.draw(scene: scene, in: view)
    }
    
    // MARK: - Private
    private func updateGameState(deltaTime: Float) {
        if input.keyPressed.contains(.upArrow) {
            input.keyPressed.remove(.upArrow)
            rotate = true
        }
        if input.keyPressed.contains(.downArrow) {
            gameDelay = 0.05
        }
        
        let leftPressed = input.keyPressed.contains(.leftArrow)
        let rightPressed = input.keyPressed.contains(.rightArrow)
        if leftPressed || rightPressed {
            if inputTimer == 0 || inputTimer > inputDelay {
                dx = leftPressed ? -1 : 1
                
                for i in 0..<4 {
                    prevTetraminoPos[i] = currTetraminoPos[i]
                    currTetraminoPos[i].x += dx
                }

                if !check() {
                    currTetraminoPos = prevTetraminoPos
                }
            }
            inputTimer += deltaTime
        }
        else {
            inputTimer = 0
        }
        
        if rotate {
            let center = currTetraminoPos[1]
            for i in 0..<4 {
                let x = currTetraminoPos[i].y - center.y
                let y = currTetraminoPos[i].x - center.x
                currTetraminoPos[i].x = center.x - x
                currTetraminoPos[i].y = center.y + y
            }
            if !check() {
                currTetraminoPos = prevTetraminoPos
            }
        }
        
        if gameTimer > gameDelay {
            for i in 0..<4 {
                prevTetraminoPos[i] = currTetraminoPos[i]
                currTetraminoPos[i].y += 1
            }
            if !check() {
                for i in 0..<4 {
                    field[prevTetraminoPos[i].y][prevTetraminoPos[i].x] = 1
                    scene.addBlock([prevTetraminoPos[i].y, prevTetraminoPos[i].x], with: currentColor)
                }
                newTetramino()
            }
            gameTimer = 0
        }
        
        var k = kFieldHeight - 1
        for i in stride(from: kFieldHeight - 1, to: 0, by: -1) {
            var count = 0
            for j in 0..<kFieldWidth {
                if field[i][j] != 0 {
                    count += 1
                }
                field[k][j] = field[i][j]
                scene.rearangeBlocks([i, j, k])
            }
            if count < kFieldWidth {
                k -= 1
            }
        }
        
        dx = 0
        rotate = false
        gameDelay = 0.3
    }
    
    private func newTetramino() {
        let n = Int.random(in: 0..<blocks.count)
        currentColor = colors[n]
        for i in 0..<4 {
            currTetraminoPos[i].x = blocks[n][i] % 2 + kFieldWidth / 2 - 1
            currTetraminoPos[i].y = blocks[n][i] / 2
        }
    }
    
    private func check() -> Bool {
        for i in 0..<4 {
            if currTetraminoPos[i].x < 0 || currTetraminoPos[i].y < 0 || currTetraminoPos[i].x >= kFieldWidth || currTetraminoPos[i].y >= kFieldHeight {
                return false
            }
            else if field[currTetraminoPos[i].y][currTetraminoPos[i].x] != 0 {
                return false
            }
        }
        return true
    }
}
