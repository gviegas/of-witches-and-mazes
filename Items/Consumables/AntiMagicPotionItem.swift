//
//  AntiMagicPotionItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Anti-Magic Potion, which reduces magic damage taken.
///
class AntiMagicPotionItem: UsableItem, TradableItem, StackableItem, DescribableItem, ActionDelegate,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.bluePotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Anti-Magic Potion"
    let icon: Icon = IconSet.Item.bluePotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 440
    var stack: ItemStack
    
    /// The condition applied by the item.
    ///
    let immunity = ImmunityCondition(damageType: .magical, isExclusive: true, isResettable: false,
                                     duration: 10.0, source: nil, color: .warded, sfx: SoundFXSet.FX.glass)
    
    required init(quantity: Int) {
        let capacity = AntiMagicPotionItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return AntiMagicPotionItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return AntiMagicPotionItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("AntiMagicPotionItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("AntiMagicPotionItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        let _ = entity.component(ofType: ConditionComponent.self)?.applyCondition(immunity)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Grants immunity to \(immunity.damageType.rawValue) damage.
        Lasts \(Int(immunity.duration!.rounded())) seconds.
        Drinking additional potions will not extend the duration.
        """
    }
}
