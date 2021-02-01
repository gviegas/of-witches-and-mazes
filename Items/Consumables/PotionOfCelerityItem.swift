//
//  PotionOfCelerityItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Potion of Celerity, a potion that increases speed of movement.
///
class PotionOfCelerityItem: UsableItem, TradableItem, StackableItem, DescribableItem, ActionDelegate,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.beigePotion.imageName]
    }
    
    static let capacity: Int = 20
    
    let name: String = "Potion of Celerity"
    let icon: Icon = IconSet.Item.beigePotion
    let category: ItemCategory = .consumable
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 385
    var stack: ItemStack
    
    /// The condition applied by the item.
    ///
    let haste = HastenCondition(hasteFactor: 0.8, isExclusive: true, isResettable: false, duration: 10.0,
                                source: nil, color: nil, sfx: SoundFXSet.FX.crystal)

    required init(quantity: Int) {
        let capacity = PotionOfCelerityItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
    }
    
    func copy() -> Item {
        return PotionOfCelerityItem(quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return PotionOfCelerityItem(quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("PotionOfCelerityItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("PotionOfCelerityItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4,
                                        sfx: (nil, SoundFXSet.FX.drinking, nil))
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        let _ = entity.component(ofType: ConditionComponent.self)?.applyCondition(haste)
        let _ = entity.component(ofType: InventoryComponent.self)?.removeItem(self)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases movement speed by \(Int((haste.hasteFactor * 100.0).rounded()))%.
        Lasts \(Int(haste.duration!.rounded())) seconds.
        Drinking additional potions will not extend the duration.
        """
    }
}
