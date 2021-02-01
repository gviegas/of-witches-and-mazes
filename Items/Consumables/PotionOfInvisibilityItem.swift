//
//  PotionOfInvisibilityItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Potion of Invisibility, a potion that causes invisibility.
///
class PotionOfInvisibilityItem: UsableItem, TradableItem, StackableItem, DescribableItem, ActionDelegate,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.glaucousPotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Potion of Invisibility"
    let icon: Icon = IconSet.Item.glaucousPotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 530
    var stack: ItemStack
    
    /// The condition applied by the item.
    ///
    let invisibility = ConcealCondition(isResettable: false, duration: 10.0, source: nil,
                                        sfx: SoundFXSet.FX.hide)

    required init(quantity: Int) {
        let capacity = PotionOfInvisibilityItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return PotionOfInvisibilityItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return PotionOfInvisibilityItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("PotionOfInvisibilityItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("PotionOfInvisibilityItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        let _ = entity.component(ofType: ConditionComponent.self)?.applyCondition(invisibility)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Causes invisibility.
        Lasts \(Int(invisibility.duration!.rounded())) seconds.
        Drinking additional potions will not extend the duration.
        """
    }
}
