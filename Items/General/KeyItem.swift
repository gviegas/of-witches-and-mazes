//
//  KeyItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/18/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines a key, used to open locked chests.
///
class KeyItem: TradableItem, StackableItem, DescribableItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.key.imageName]
    }
    
    static let capacity: Int = 30
    
    let name: String = "Key"
    let icon: Icon = IconSet.Item.key
    let category: ItemCategory = .general
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = false
    let price: Int = 385
    var stack: ItemStack
    
    required init(quantity: Int) {
        let capacity = KeyItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return KeyItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return KeyItem(quantity: stackCount)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Unlocks treasure chests.
        """
    }
}
