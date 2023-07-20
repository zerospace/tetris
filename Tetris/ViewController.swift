//
//  ViewController.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 10.05.2023.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    private var mtkView: MTKView!
    private var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = self.view as? MTKView else {
            print("Attached view is not MTKView")
            return
        }
        self.mtkView = mtkView
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        print("[GPU]: \(defaultDevice)")
        self.mtkView.device = defaultDevice
        
        do {
            let renderer = try Renderer(with: self.mtkView)
            self.renderer = renderer
            self.mtkView.delegate = self.renderer
        }
        catch {
            print("Renderer Error: \(error)")
        }        
    }
}

