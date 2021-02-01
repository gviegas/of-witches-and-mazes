//
//  DeadlyDraughtItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Deadly Draught, a potion that kills the drinker.
///
class DeadlyDraughtItem: UsableItem, TradableItem, StackableItem, DescribableItem, ActionDelegate,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.rufousPotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Deadly Draught"
    let icon: Icon = IconSet.Item.rufousPotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 47
    var stack: ItemStack

    required init(quantity: Int) {
        let capacity = DeadlyDraughtItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return DeadlyDraughtItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return DeadlyDraughtItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("DeadlyDraughtItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("DeadlyDraughtItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
        if let healthComponent = entity.component(ofType: HealthComponent.self) {
            healthComponent.causeDamage(healthComponent.currentHP)
        }
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Causes death.
        """
    }
}
