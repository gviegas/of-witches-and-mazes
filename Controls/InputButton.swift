//
//  InputButton.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that defines the input buttons for game actions.
///
enum InputButton: Int, Codable {
    case up, down, left, right
    case interact
    case item1, item2, item3, item4, item5, item6
    case skill1, skill2, skill3, skill4, skill5
    case cycleTargets, clearTarget
    case pause, character
    case confirm, cancel, back
    
    /// Retrieves the `String` that symbolizes the button, taken from the current mapping.
    ///
    /// - Note: If the button is not mapped, this property will produce an empty string.
    ///
    var symbolFromMapping: String {
        guard let mapping = KeyboardMapping.mappingFor(inputButton: self) else { return "" }
        
        var part = [String]()
        for (keyCode, modifiers) in mapping {
            guard let str = KeyboardMapping.convertMappingToSymbol(keyCode: keyCode, modifiers: modifiers) else {
                continue
            }
            part.append(str)
        }
        
        if part.isEmpty {
            return ""
        } else if part.count == 1 {
            return part.first!
        } else {
            var str = part[0]
            for i in 1..<part.count { str += " or \(part[i])" }
            return str
        }
    }
    
    /// Retrieves the first `String` that symbolizes the button, taken from the current mapping.
    /// Unlike `symbolFromMapping`, this getter will produce only the symbol representing the first mapping.
    ///
    /// - Note: If the button is not mapped, this property will produce an empty string.
    ///
    var firstSymbolFromMapping: String {
        guard let mapping = KeyboardMapping.mappingFor(inputButton: self) else { return "" }
        
        let (keyCode, modifiers) = mapping.first!
        return KeyboardMapping.convertMappingToSymbol(keyCode: keyCode, modifiers: modifiers) ?? ""
    }
    
    /// The list containing all movement buttons.
    ///
    static let movementButtons: [InputButton] = [.up, .down, .left, .right,]
    
    /// The list containig all item buttons (sorted).
    ///
    static let itemButtons: [InputButton] = [.item1, .item2, .item3, .item4, .item5, .item6]
    
    /// The list containing all skill buttons (sorted).
    ///
    static let skillButtons: [InputButton] = [.skill1, .skill2, .skill3, .skill4, .skill5]
    
    /// The list containing all action buttons - movement, interaction, items and skills.
    ///
    static let actionButtons: [InputButton] = [.up, .down, .left, .right, .interact,
                                               .item1, .item2, .item3, .item4, .item5, .item6,
                                               .skill1, .skill2, .skill3, .skill4, .skill5]
}
