//
//  Medium.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that defines the types of media for effects.
///
enum Medium: String, Comparable {
    case none = "None"
    case melee = "Melee"
    case ranged = "Ranged"
    case spell = "Spell"
    case power = "Power"
    case gadget = "Gadget"
    
    static func < (lhs: Medium, rhs: Medium) -> Bool {
        let order: [Medium: Int] = [.none: 0, melee: 1, .ranged: 2, .spell: 3, .power: 4, .gadget: 5]
        return order[lhs]! < order[rhs]!
    }
}
