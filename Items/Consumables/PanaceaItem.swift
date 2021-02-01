//
//  PanaceaItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Panacea, a potion that fully restores HP.
///
class PanaceaItem: UsableItem, TradableItem, StackableItem, DescribableItem, HealingItem, ActionDelegate,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.yellowPotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Panacea"
    let icon: Icon = IconSet.Item.yellowPotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 160
    var stack: ItemStack
    
    let healing: Healing = Healing(percentage: 1.0...1.0, sfx: nil)
    
    required init(quantity: Int) {
        let capacity = PanaceaItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return PanaceaItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return PanaceaItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("PanaceaItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("PanaceaItem can only be used by an entity that has an ActionComponent")
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
        Restores all health points.
        """
    }
}
