//
//  LevelItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that is based on a given level of experience.
///
/// - Note: Due to the way that items are managed by the `InventoryComponent`, a `LevelItem` that
///   also is a `StackableItem` must have unique `name` values for each level.
///
protocol LevelItem: Item {
    
    /// The level of the item.
    ///
    var itemLevel: Int { get }
    
    /// The required experience level that an entity must attain to use/equip the item.
    ///
    var requiredLevel: Int { get }
    
    /// Creates a new instance for the given experience level.
    ///
    /// - Parameter level: The level of experience which the item must represent.
    ///
    init(level: Int)
}
