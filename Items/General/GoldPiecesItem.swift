//
//  GoldPiecesItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/16/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines an amount of gold pieces, used in trades.
///
class GoldPiecesItem: StackableItem, DescribableItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.goldPieces.imageName]
    }
    
    static let capacity: Int = 5000
    
    let name: String = "Gold Pieces"
    let icon: Icon = IconSet.Item.goldPieces
    let category: ItemCategory = .general
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = false
    var stack: ItemStack

    required init(quantity: Int) {
        let capacity = GoldPiecesItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return GoldPiecesItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return GoldPiecesItem(quantity: stackCount)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        The local currency.
        """
    }
}
