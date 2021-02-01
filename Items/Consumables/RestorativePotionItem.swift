//
//  RestorativePotionItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/13/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Restorative Potion, a potion that restores health points over time.
///
class RestorativePotionItem: UsableItem, TradableItem, StackableItem, DescribableItem, HealingOverTimeItem,
ActionDelegate, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.pinkPotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Restorative Potion"
    let icon: Icon = IconSet.Item.pinkPotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 32
    var stack: ItemStack
    
    let healingOverTime = HealingOverTimeCondition(tickTime: 1.0,
                                                   tickHealing: Healing(percentage: 0.1...0.1, sfx: nil),
                                                   isExclusive: true,
                                                   isResettable: true,
                                                   duration: 7.1,
                                                   source: nil,
                                                   color:  nil,
                                                   sfx: nil)
    
    required init(quantity: Int) {
        let capacity = RestorativePotionItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return RestorativePotionItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return RestorativePotionItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("RestorativePotionItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("RestorativePotionItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        let _ = entity.component(ofType: ConditionComponent.self)?.applyCondition(healingOverTime)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Restores health points over time.
        """
    }
}
