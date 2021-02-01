//
//  GrimoireOfDazeItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Grimoire of Daze, used to cast the Daze spell.
///
class GrimoireOfDazeItem: UsableItem, TradableItem, DescribableItem, ResourceItem, InitializableItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.yellowTome.imageName]
    }
    
    let name: String = "Grimoire of Daze"
    let icon: Icon = IconSet.Item.yellowTome
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 223
    
    let resourceName = "Spell Components"
    let resourceCost = 2
    
    let touch: Touch = DazeTouch(duration: 1.0)
    
    required init() {}
    
    func copy() -> Item {
        return GrimoireOfDazeItem()
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfDazeItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfDazeItem can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that interrupts the selected target.
        """
    }
}

/// The `Touch` type representing the Daze spell effect.
///
fileprivate class DazeTouch: Touch {
    
    let isHostile: Bool = true
    let range: CGFloat = 525.0
    let delay: TimeInterval = 0
    let duration: TimeInterval = 0
    let conclusion: TimeInterval = 0
    let animation: Animation? = nil
    let sfx: SoundFX? = nil
    
    /// The quell condition that the touch applies.
    ///
    let daze: QuellCondition
    
    /// Creates a new instance from the given duration.
    ///
    /// - Parameter duration: The duration of the quell condition.
    ///
    init(duration: TimeInterval) {
        daze = QuellCondition(quelling: Quelling(breakOnDamage: true, makeVulnerable: false, duration: duration),
                              source: nil, color: nil, sfx: SoundFXSet.FX.disorient)
    }
    
    func didTouch(target: Entity, source: Entity?) {
        daze.source = source
        Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: nil, conditions: [daze])
    }
}
