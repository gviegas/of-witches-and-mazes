//
//  KeyboardEvent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that defines the modifier keys of the keyboard.
///
enum KeyboardModifierKey: UInt, Codable {
    case none = 0
    case control = 0x01
    case shift = 0x02
    
    /// The string that represents the modifier.
    ///
    var asString: String {
        switch self {
        case .none:
            return ""
        case .control:
            return "c-"
        case .shift:
            return "s-"
        }
    }
    
    /// Computes a list of modifiers from a given mask.
    ///
    /// - Parameter mask: A mask from which to perform logical AND operation with every modifier.
    /// - Returns: A list containing all modifiers whose raw value was successfuly compared to the given mask.
    ///
    static func fromMask(_ mask: UInt) -> [KeyboardModifierKey] {
        var modifiers = [KeyboardModifierKey]()
        [KeyboardModifierKey.shift, KeyboardModifierKey.control].forEach {
            if ($0.rawValue & mask) != 0 { modifiers.append($0) }
        }
        return modifiers
    }
}

/// An `Event` type for keyboard input.
///
class KeyboardEvent: Event {
    
    let type: EventType
    
    /// The literal characters that represent the key.
    ///
    let characters: String
    
    /// The hardware-independent key code.
    ///
    let keyCode: UInt
    
    /// The `KeyboardModifierKey` modifiers.
    ///
    let modifiers: UInt
    
    /// A flag stating whether or not the event is repeating.
    ///
    let isRepeating: Bool
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - type: The type of the event.
    ///   - characters: The literal characters that represent the key.
    ///   - keyCode: The hardware-independent key code.
    ///   - modifiers: The `KeyboardModifierKey` modifiers.
    ///   - isRepeating: A flag stating whether or not the event is repeating.
    ///
    private init(type: EventType, characters: String, keyCode: UInt, modifiers: UInt, isRepeating: Bool) {
        self.type = type
        self.characters = characters
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.isRepeating = isRepeating
    }
    
    /// Creates a new `KeyboardEvent` representing a key down event.
    ///
    /// - Parameters:
    ///   - characters: The literal characters that represent the key.
    ///   - keyCode: The hardware-independent key code.
    ///   - modifiers: The `KeyboardModifierKey` modifiers.
    ///   - isRepeating: A flag stating whether or not the event is repeating.
    /// - Returns: A new `KeyboardEvent`.
    ///
    class func keyDownEvent(characters: String, keyCode: UInt, modifiers: UInt, isRepeating: Bool) -> KeyboardEvent {
        return KeyboardEvent(type: .keyDown, characters: characters, keyCode: keyCode,
                             modifiers: modifiers, isRepeating: isRepeating)
    }
    
    /// Creates a new `KeyboardEvent` representing a key up event.
    ///
    /// - Parameters:
    ///   - characters: The literal characters that represent the key.
    ///   - keyCode: The hardware-independent key code.
    /// - Returns: A new `KeyboardEvent`.
    ///
    class func keyUpEvent(characters: String, keyCode: UInt) -> KeyboardEvent {
        return KeyboardEvent(type: .keyUp, characters: characters, keyCode: keyCode,
                             modifiers: KeyboardModifierKey.none.rawValue, isRepeating: false)
    }
}
