//
//  ItemMaker.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/19/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that makes `Item` instances.
///
struct ItemMaker {
    
    private init() {}
    
    /// Makes a new `Item` instance of `itemClass` type.
    ///
    /// - Parameters:
    ///   - itemClass: The class type of the `Item` to make.
    ///   - level: An optional item level. This parameter only applies to `LevelItem` types.
    ///   - quantity: An optional quantity. This parameter only applies to `StackableItem` types.
    /// - Returns: A new instance of `itemClass` type, or `nil` if it could not be created.
    ///
    static func makeItem(itemClass: Item.Type, level: Int?, quantity: Int?) -> Item? {
        var item: Item?
        
        // Attempt to create as `LevelItem`
        if let level = level {
            item = (itemClass as? LevelItem.Type)?.init(level: level)
            if let quantity = quantity, let item = item as? StackableItem {
                let _ = item.stack.push(amount: quantity - 1)
            }
        }
        
        guard item == nil else { return item }
        
        // Attempt to create as `StackableItem`
        if let quantity = quantity {
            item = (itemClass as? StackableItem.Type)?.init(quantity: quantity)
        }
        
        guard item == nil else { return item }
        
        // Attempt to create as `InitializableItem`
        item = (itemClass as? InitializableItem.Type)?.init()
        
        return item
    }
}
