//
//  Pack.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines a set of items owned, representing the contents of an `InventoryComponent` and
/// the equipment of an `EquipmentComponent`.
///
class Pack {
    
    /// The list containing all the items in the pack.
    ///
    let items: [Item]
    
    /// The list containing only the items of the pack that are equipped.
    ///
    let equipment: [Item]
    
    /// Creates a new instance from the given items and equipment.
    ///
    /// - Note: The `equipment` list cannot hold any instance that is not present in the `items` list.
    ///
    /// - Parameters:
    ///   - items: The list containing all the items in the pack.
    ///   - equipment: The list containing only the items of the pack that are equipped.
    ///
    init(items: [Item], equipment: [Item]) {
        assert(equipment.allSatisfy({ item in items.contains(where: { $0 === item }) }))
        
        self.items = items
        self.equipment = equipment
    }
}
