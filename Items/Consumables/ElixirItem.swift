//
//  ElixirItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Elixir, a potion that cures curse.
///
class ElixirItem: UsableItem, TradableItem, StackableItem, DescribableItem, ActionDelegate, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.purplePotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Elixir"
    let icon: Icon = IconSet.Item.purplePotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 65
    var stack: ItemStack
    
    required init(quantity: Int) {
        let capacity = ElixirItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return ElixirItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return ElixirItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("ElixirItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("ElixirItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        entity.component(ofType: ConditionComponent.self)?.removeAllConditions(ofType: CurseCondition.self)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Cures curse.
        """
    }
}
