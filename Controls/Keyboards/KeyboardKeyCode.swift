//
//  KeyboardKeyCode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that names the device-independent key codes.
///
enum KeyboardKeyCode: UInt, Codable {
    case q = 0x0c
    case w = 0x0d
    case e = 0x0e
    case r = 0x0f
    case t = 0x11
    case y = 0x10
    case u = 0x20
    case i = 0x22
    case o = 0x1f
    case p = 0x23
    case a = 0x00
    case s = 0x01
    case d = 0x02
    case f = 0x03
    case g = 0x05
    case h = 0x04
    case j = 0x26
    case k = 0x28
    case l = 0x25
    case z = 0x06
    case x = 0x07
    case c = 0x08
    case v = 0x09
    case b = 0x0b
    case n = 0x2d
    case m = 0x2e
    case graveAccent = 0x32
    case num1 = 0x12
    case num2 = 0x13
    case num3 = 0x14
    case num4 = 0x15
    case num5 = 0x17
    case num6 = 0x16
    case num7 = 0x1a
    case num8 = 0x1c
    case num9 = 0x19
    case num0 = 0x1d
    case minus = 0x1b
    case equal = 0x18
    case bracketLeft = 0x21
    case bracketRight = 0x1e
    case backslash = 0x2a
    case semicolon = 0x29
    case apostrophe = 0x27
    case comma = 0x2b
    case period = 0x2f
    case slash = 0x2c
    case enter = 0x24
    case escape = 0x35
    case space = 0x31
    case delete = 0x33
    case tab = 0x30
    case arrowLeft = 0x7b
    case arrowRight = 0x7c
    case arrowDown = 0x7d
    case arrowUp = 0x7e
    
    /// The dictionary containing the strings that represent the key codes.
    ///
    /// Initially, this dictionary contains only strings that are independent of keyboard layout.
    /// As the method `asString()` is used to retrieve the strings representing key codes, it will
    /// populate the dictionary with missing values that vary across keyboard layouts.
    ///
    private static var strings: [KeyboardKeyCode: String] = [enter: "return",
                                                             escape: "esc",
                                                             space: "space",
                                                             delete: "delete",
                                                             tab: "tab",
                                                             arrowLeft: "left",
                                                             arrowRight: "right",
                                                             arrowDown: "down",
                                                             arrowUp: "up"]
    
    /// The string that represents the key code, which may be an empty string.
    ///
    /// - Note: Keyboard-dependent strings (i.e., unicode strings associated with a key that vary across
    ///   keyboard layouts) will be retrieved only once, when this getter is first accessed. Thus, changing
    ///   the keyboard layout afterwards may cause inconsistencies with key code representation.
    ///
    var asString: String {
        if let storedValue = KeyboardKeyCode.strings[self] {
            return storedValue
        }
        
        if let event = CGEvent(keyboardEventSource: nil, virtualKey: UInt16(rawValue), keyDown: true) {
            var len = Int()
            var str = [UInt16]()
            event.keyboardGetUnicodeString(maxStringLength: 2, actualStringLength: &len, unicodeString: &str)
            KeyboardKeyCode.strings[self] = String(utf16CodeUnits: str, count: len).uppercased()
            return KeyboardKeyCode.strings[self]!
        }
        
        return ""
    }
    
    /// The flag stating whether the key code represents a special key. Special keys are keys that must
    /// not be remapped.
    ///
    var isSpecialKey: Bool {
        switch self {
        case .enter, .escape, .delete, .arrowLeft, .arrowRight, .arrowDown, .arrowUp:
            return true
        default:
            return false
        }
    }
}
