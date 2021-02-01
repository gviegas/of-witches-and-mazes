//
//  GrimoireOfWeakness.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/13/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Grimoire of Weakness, used to cast the Weakness spell.
///
class GrimoireOfWeaknessItem: UsableItem, TradableItem, DescribableItem, ResourceItem, InitializableItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.purpleBook.imageName]
    }
    
    let name: String = "Grimoire of Weakness"
    let icon: Icon = IconSet.Item.purpleBook
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 730
    
    let resourceName = "Spell Components"
    let resourceCost = 8
    
    let touch: Touch = WeaknessTouch(damageCausedReduction: 0.3, duration: 10.0)
    
    required init() {}
    
    func copy() -> Item {
        return GrimoireOfWeaknessItem()
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfWeaknessItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfWeaknessItem can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        let reduction = (touch as! WeaknessTouch).weakness.damageCausedReduction
        let duration = (touch as! WeaknessTouch).weakness.duration!
        
        return """
        Casts a spell that weakens the seleted target. A weakened creature causes \(Int(reduction * 100.0))% \
        less damage.
        Lasts \(Int(duration.rounded())) seconds.
        """
    }
}

/// The `Touch` type representing the Weakness spell effect.
///
fileprivate class WeaknessTouch: Touch {
    
    let isHostile: Bool = true
    let range: CGFloat = 525.0
    let delay: TimeInterval = 0
    let duration: TimeInterval = 0
    let conclusion: TimeInterval = 0
    let animation: Animation? = nil
    let sfx: SoundFX? = nil
    
    /// The weaken condition that the touch applies.
    ///
    let weakness: WeakenCondition
    
    /// Creates a new instance from the given damage reduction and duration.
    ///
    /// - Parameters:
    ///   - damageCausedReduction: A value between `0` and `1.0` to be subtracted from all
    ///     damage caused by the affected target.
    ///   - duration: The duration of the weaken condition.
    ///
    init(damageCausedReduction: Double, duration: TimeInterval) {
        weakness = WeakenCondition(damageCausedReduction: damageCausedReduction, isExclusive: true,
                                   isResettable: true, duration: duration, source: nil, color: nil,
                                   sfx: SoundFXSet.FX.cutter)
    }
    
    func didTouch(target: Entity, source: Entity?) {
        weakness.source = source
        Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: nil, conditions: [weakness])
    }
}
