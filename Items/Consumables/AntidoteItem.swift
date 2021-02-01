//
//  AntidoteItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Antidote, a potion that cures poison.
///
class AntidoteItem: UsableItem, TradableItem, StackableItem, DescribableItem, ActionDelegate, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.greenPotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Antidote"
    let icon: Icon = IconSet.Item.greenPotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 34
    var stack: ItemStack
    
    required init(quantity: Int) {
        let capacity = AntidoteItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return AntidoteItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return AntidoteItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("AntidoteItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("AntidoteItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        entity.component(ofType: ConditionComponent.self)?.removeAllConditions(ofType: PoisonCondition.self)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Cures poison.
        """
    }
}
