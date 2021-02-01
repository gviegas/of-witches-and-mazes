//
//  InputManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the input manager, used to manage the global input state.
///
class InputManager {
    
    private init() {}
    
    /// The location of the cursor in the current scene.
    ///
    static var cursorLocation: CGPoint {
        return MouseInputManager.location
    }
    
    /// Checks if a given input button is being pressed.
    ///
    /// - Parameter inputButton: The input button to check.
    /// - Returns: `true` is the button is set as pressed, `false` otherwise.
    ///
    class func isPressed(inputButton: InputButton) -> Bool {
        let pressedKeys = KeyboardInputManager.allPressedKeys()
        for (keyCode, modifiers) in pressedKeys {
            if let mapping = KeyboardMapping.mappingFor(keyCode: keyCode, modifiers: modifiers),
                mapping.contains(inputButton) { return true }
        }
        return false
    }
}
