//
//  KeyboardMapping.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the mapping of keyboard keys to input buttons.
///
class KeyboardMapping {
    
    /// A class defining the `Observable` type for the static `KeyboardMapping`.
    ///
    class KeyboardMappingObservable: Observable {
        
        /// The instance of the class. Observers that which to be notified of changes regarding the
        /// `KeyboardMapping` static class must register themselves with this instance.
        ///
        static let instance = KeyboardMappingObservable()
        
        /// The registered observes.
        ///
        private var observers = [ObjectIdentifier: Observer]()
        
        private init() {}
        
        func register(observer: Observer) {
            observers[ObjectIdentifier(observer)] = observer
        }
        
        func remove(observer: Observer) {
            observers[ObjectIdentifier(observer)] = nil
        }
        
        func broadcast() {
            for (_, observer) in observers {
                observer.didChange(observable: self)
            }
        }
    }
    
    /// A struct that wraps an entry for a button mapping dictionary.
    ///
    private struct ButtonMappingEntry: Hashable {
        let keyCode: UInt
        let modifiers: UInt
    }
    
    /// The mapping as a [keyCode: [modifiers: Set<InputButton>]] collection.
    ///
    private static var keyMapping: [UInt: [UInt: Set<InputButton>]] = [:]
    
    /// The mapping as a [InputButton: Set<ButtonMappingEntry>] collection.
    ///
    private static var buttonMapping: [InputButton: Set<ButtonMappingEntry>] = [:]
    
    /// The list holding the current mapping.
    ///
    static var mapping: [(keyCode: UInt, modifiers: UInt, Set<InputButton>)] {
        var entries = [(UInt, UInt, Set<InputButton>)]()
        for (keyCode, modifiersMapping) in keyMapping {
            for (modifiers, buttons) in modifiersMapping {
                entries.append((keyCode, modifiers, buttons))
            }
        }
        return entries
    }
    
    private init() {}
    
    /// Retrieves a key mapping.
    ///
    /// - Parameters:
    ///   - keyCode: The hardware-independent key code.
    ///   - modifiers: The optional `KeyboardModifierKey` modifiers. If set to `nil`, all mappings
    ///     for the given `keyCode` are retrieved.
    /// - Returns: The `InputButton` instances mapped under the given `keyCode` and `modifiers`,
    ///   or `nil` if nothing is mapped for the key.
    ///
    class func mappingFor(keyCode: UInt, modifiers: UInt?) -> Set<InputButton>? {
        guard let modifiersMapping = keyMapping[keyCode] else { return nil }
        
        let inputButtons: Set<InputButton>?
        if let modifiers = modifiers {
            inputButtons = keyMapping[keyCode]?[modifiers]
        } else {
            inputButtons = modifiersMapping.reduce(Set<InputButton>()) { (result, entry) in
                return result.union(entry.value)
            }
        }
        return inputButtons
    }
    
    /// Retrieves the mapping for the given input button.
    ///
    /// - Parameter inputButton: The input button whose mapping should be retrieved.
    /// - Returns: A list of `(keyCode, modifiers)` tuples representing the mapping,
    ///   or `nil` if nothing is mapped for the button.
    ///
    class func mappingFor(inputButton: InputButton) -> [(keyCode: UInt, modifiers: UInt)]? {
        guard let values = buttonMapping[inputButton] else { return nil }
        return (values.map { ($0.keyCode, $0.modifiers) }).sorted(by: <)
    }
    
    /// Maps a key.
    ///
    /// - Parameters:
    ///   - keyCode: The hardware-independent key code.
    ///   - modifiers: The `KeyboardModifierKey` modifiers.
    ///   - inputButtons: The `InputButton` instances to be mapped for the key.
    ///
    class func map(keyCode: UInt, modifiers: UInt, inputButtons: Set<InputButton>) {
        if let mappedButtons = keyMapping[keyCode]?[modifiers] {
            keyMapping[keyCode]![modifiers] = mappedButtons.union(inputButtons)
        } else if let _ = keyMapping[keyCode] {
            keyMapping[keyCode]![modifiers] = inputButtons
        } else {
            keyMapping[keyCode] = [modifiers: inputButtons]
        }
        
        for button in inputButtons {
            let entry = ButtonMappingEntry(keyCode: keyCode, modifiers: modifiers)
            if let _ = buttonMapping[button] {
                buttonMapping[button]!.insert(entry)
            } else {
                buttonMapping[button] = [entry]
            }
        }
        
        KeyboardMappingObservable.instance.broadcast()
    }
    
    /// Unmaps a key.
    ///
    /// - Parameters:
    ///   - keyCode: The hardware-independent key code.
    ///   - modifiers: The `KeyboardModifierKey` modifiers.
    ///   - inputButtons: The `InputButton` instances to be unmapped from the key, or `nil`
    ///     if all input buttons of the given key should be unmapped.
    ///
    class func unmap(keyCode: UInt, modifiers: UInt, inputButtons: Set<InputButton>?) {
        if let inputButtons = inputButtons {
            if let mappedButtons = keyMapping[keyCode]?[modifiers] {
                keyMapping[keyCode]![modifiers] = mappedButtons.subtracting(inputButtons)
                if keyMapping[keyCode]![modifiers]!.isEmpty {
                    keyMapping[keyCode]![modifiers] = nil
                    if keyMapping[keyCode]!.isEmpty { keyMapping[keyCode] = nil }
                }
                let entry = ButtonMappingEntry(keyCode: keyCode, modifiers: modifiers)
                inputButtons.forEach {
                    buttonMapping[$0]?.remove(entry)
                    if buttonMapping[$0]?.isEmpty == true { buttonMapping[$0] = nil }
                }
            }
        } else {
            let entry = ButtonMappingEntry(keyCode: keyCode, modifiers: modifiers)
            keyMapping[keyCode]?[modifiers]?.forEach {
                buttonMapping[$0]?.remove(entry)
                if buttonMapping[$0]?.isEmpty == true { buttonMapping[$0] = nil }
            }
            keyMapping[keyCode]?[modifiers] = nil
            if keyMapping[keyCode]?.isEmpty == true { keyMapping[keyCode] = nil }
        }
        
        KeyboardMappingObservable.instance.broadcast()
    }
    
    /// Maps a set of keys.
    ///
    /// - Parameter entries: An array of `(keyCode, modifiers, inputButtons)` tuples to map.
    ///
    class func mapMany(entries: [(keyCode: UInt, modifiers: UInt, inputButtons: Set<InputButton>)]) {
        for (keyCode, modifiers, inputButtons) in entries {
            map(keyCode: keyCode, modifiers: modifiers, inputButtons: inputButtons)
        }
    }
    
    /// Unmaps all keys.
    ///
    class func unmapAll() {
        keyMapping = [:]
        buttonMapping = [:]
        KeyboardMappingObservable.instance.broadcast()
    }
    
    /// Converts a key mapping to a symbolic `String` representation.
    ///
    /// - Parameters:
    ///   - keyCode: The hardware-independent key code of the mapping.
    ///   - modifiers: The `KeyboardModifierKey` modifiers of the mapping.
    /// - Returns: A `String` representing the mapping, or `nil` if the conversion failed.
    ///   A conversion fails when the key code is invalid or the resulting symbol is an empty string.
    ///
    class func convertMappingToSymbol(keyCode: UInt, modifiers: UInt) -> String? {
        guard let keyCodeStr = KeyboardKeyCode(rawValue: keyCode)?.asString else { return nil }
        
        let modifiersStr = KeyboardModifierKey.fromMask(modifiers).reduce("") { (result, modifier) in
            result + modifier.asString
        }
        
        let str = modifiersStr + keyCodeStr
        if str != "" { return str }
        return nil
    }
}
