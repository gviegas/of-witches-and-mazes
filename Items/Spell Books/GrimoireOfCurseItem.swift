//
//  GrimoireOfCurseItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Grimoire of Curse, used to cast the Curse spell.
///
class GrimoireOfCurseItem: UsableItem, TradableItem, DescribableItem, ResourceItem, InitializableItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.redGrimoire.imageName]
    }
    
    let name: String = "Grimoire of Curse"
    let icon: Icon = IconSet.Item.redGrimoire
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 4500
    
    let resourceName = "Spell Components"
    let resourceCost = 20
    
    let touch: Touch = CurseTouch(reductionFactor: 0.25, duration: 10.0)
    
    required init() {}
    
    func copy() -> Item {
        return GrimoireOfCurseItem()
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfCurseItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfCurseItem can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        let reduction = (touch as! CurseTouch).curse.reductionFactor
        let duration = (touch as! CurseTouch).curse.duration!
        
        return """
        Casts a spell that curses the seleted target, reducing its total health points \
        by \(Int(reduction * 100.0))%.
        Lasts \(Int(duration.rounded())) seconds.
        """
    }
}

/// The `Touch` type representing the Curse spell effect.
///
fileprivate class CurseTouch: Touch {
    
    let isHostile: Bool = true
    let range: CGFloat = 315.0
    let delay: TimeInterval = 0
    let duration: TimeInterval = 0
    let conclusion: TimeInterval = 0
    let animation: Animation? = nil
    let sfx: SoundFX? = nil
    
    /// The curse condition that the touch applies.
    ///
    let curse: CurseCondition
    
    /// Creates a new instance from the given reduction factor and duration.
    ///
    /// - Parameters:
    ///   - reductionFactor: A value between `0` and `1.0` to be subtracted from the target's health.
    ///   - duration: The duration of the weaken condition.
    ///
    init(reductionFactor: Double, duration: TimeInterval) {
        curse = CurseCondition(reductionFactor: reductionFactor, isExclusive: true, isResettable: true,
                               duration: duration, source: nil)
    }
    
    func didTouch(target: Entity, source: Entity?) {
        curse.source = source
        Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: nil, conditions: [curse])
    }
}
