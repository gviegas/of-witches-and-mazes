//
//  KeyboardInputManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/5/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the keyboard input manager, used to manage the global input state
/// for keyboards.
///
class KeyboardInputManager {
    
    /// The pressed key codes and its modifiers.
    ///
    private static var pressedKeys: [UInt: UInt] = [:]
    
    private init() {}
    
    /// Retrieves all the keys being pressed.
    ///
    /// - Returns: An array of (keyCode, modifiers) tuples containing all the
    ///   keys currently set as pressed.
    ///
    class func allPressedKeys() -> [(keyCode: UInt, modifiers: UInt)] {
        return pressedKeys.map { ($0.key, $0.value) }
    }
    
    /// Checks if a given key is being pressed.
    ///
    /// - Parameter keyCode: The code of the key to check.
    /// - Returns: `true` is the key is set as pressed, `false` otherwise.
    ///
    class func isPressed(keyCode: UInt) -> Bool {
        return pressedKeys[keyCode] != nil
    }
    
    /// Retrieves the modifiers for the given key code.
    ///
    /// - Parameter keyCode: The key code to retrieve the modifiers for.
    /// - Returns: The modifiers for the given key code, or `nil` if the key is not pressed.
    ///
    class func modifiersOf(keyCode: UInt) -> UInt? {
        return pressedKeys[keyCode]
    }
    
    /// Sets the given key as pressed.
    ///
    /// - Parameters:
    ///   - keyCode: The code of the key to set.
    ///   - modifiers: The modifier keys to associate with the key code.
    ///
    class func setPressed(keyCode: UInt, modifiers: UInt) {
        pressedKeys[keyCode] = modifiers
    }
    
    /// Sets the given key as released.
    ///
    /// - Parameter keyCode: The code of the key to set.
    ///
    class func setReleased(keyCode: UInt) {
        pressedKeys[keyCode] = nil
    }
    
    /// Resets the state of all keys.
    ///
    /// After calling this method, all pressed keys will be released.
    ///
    class func reset() {
        pressedKeys = [:]
    }
}
