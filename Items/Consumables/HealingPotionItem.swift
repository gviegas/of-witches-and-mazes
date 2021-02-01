//
//  HealingPotionItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/25/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Healing Potion, a potion that restores health points.
///
class HealingPotionItem: UsableItem, TradableItem, StackableItem, DescribableItem, HealingItem, ActionDelegate,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.redPotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Healing Potion"
    let icon: Icon = IconSet.Item.redPotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 25
    var stack: ItemStack
    
    let healing: Healing = Healing(percentage: 0.3...0.3, sfx: nil)

    required init(quantity: Int) {
        let capacity = HealingPotionItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return HealingPotionItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return HealingPotionItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("HealingPotionItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("HealingPotionItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        healing.heal(target: entity, source: nil)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Restores health points.
        """
    }
}
