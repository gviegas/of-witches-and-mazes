//
//  Item.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/24/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum defining the available categories of items.
///
enum ItemCategory: String {
    case meleeWeapon = "Melee Weapon"
    case rangedWeapon = "Ranged Weapon"
    case throwingWeapon = "Throwing Weapon"
    case armor = "Armor"
    case shield = "Shield"
    case jewel = "Jewel"
    case gadget = "Gadget"
    case spellBook = "Spell Book"
    case consumable = "Consumable"
    case general = "General"
    
    /// The flag stating whether a category allows more than a single item to be equipped at once.
    ///
    var canEquipMany: Bool {
        switch self {
        case .general, .spellBook, .consumable:
            return true
        default:
            return false
        }
    }
}

/// A protocol that all items of the game must conform to.
///
protocol Item: AnyObject {
    
    /// The unique name of the item.
    ///
    var name: String { get }
    
    /// The icon that visually represents the item.
    ///
    var icon: Icon { get }
    
    /// The category of the item
    ///
    var category: ItemCategory { get }
    
    /// A flag indicating that no more than a single instance of the item must be owned.
    ///
    var isUnique: Bool { get }
    
    /// A flag indicating whether or not the item can be discarded.
    ///
    var isDiscardable: Bool { get }
    
    /// A flag indicating whether or not the item can be equipped.
    ///
    var isEquippable: Bool { get }
    
    /// Creates a new copy of the item.
    ///
    func copy() -> Item
}
