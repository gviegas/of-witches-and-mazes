//
//  SpellComponentsItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Spell Components, used as a resource to cast spells.
///
class SpellComponentsItem: TradableItem, StackableItem, DescribableItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.spellComponents.imageName]
    }

    static let capacity: Int = 100
    
    let name: String = "Spell Components"
    let icon: Icon = IconSet.Item.spellComponents
    let category: ItemCategory = .general
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = false
    let price: Int = 10
    var stack: ItemStack
    
    required init(quantity: Int) {
        let capacity = SpellComponentsItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return SpellComponentsItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return SpellComponentsItem(quantity: stackCount)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Material components for spells.
        """
    }
}
