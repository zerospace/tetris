//
//  InputController.swift
//  Tetris
//
//  Created by Oleksandr Fedko on 21.07.2023.
//

import GameController
import Combine

struct Point {
    var x: Float
    var y: Float
    static let zero = Point(x: 0, y: 0)
}

struct InputSettings {
    var rotationSpeed: Float { 2.0 }
    var translationSpeed: Float { 3.0 }
    var scrollSensitivity: Float { 0.1 }
    var panSensitivity: Float { 0.008 }
}

final class InputController {
    let settings: InputSettings
    
    // keyboard
    private(set) var keyPressed: Set<GCKeyCode> = []
    
    // mouse
    private(set) var leftMouseDown = false
    var mouseDelta: Point = .zero
    var mouseScroll: Point = .zero
    
    private var keyboardCancellable: Cancellable?
    private var mouseCancellable: Cancellable?
    
    init() {
        self.settings = InputSettings()
        self.keyboardCancellable = NotificationCenter.default
            .publisher(for: .GCKeyboardDidConnect)
            .sink(receiveValue: { notification in
                if let keyboard = notification.object as? GCKeyboard {
                    keyboard.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                        if pressed {
                            self.keyPressed.insert(keyCode)
                        }
                        else {
                            self.keyPressed.remove(keyCode)
                        }
                    }
                }
            })
        
        self.mouseCancellable = NotificationCenter.default
            .publisher(for: .GCMouseDidConnect)
            .sink(receiveValue: { notification in
                if let mouse = notification.object as? GCMouse {
                    mouse.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                        self.leftMouseDown = pressed
                    }
                    
                    mouse.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                        self.mouseDelta = Point(x: deltaX, y: deltaY)
                    }
                    
                    mouse.mouseInput?.scroll.valueChangedHandler = { _, x, y in
                        self.mouseScroll = Point(x: x, y: y)
                    }
                }
            })
        
        NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { _ in nil }
    }
}
