//
//  HypnotismSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/3/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Hypnotism spell.
///
class HypnotismSkill: UsableSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.handMagic.imageName]
    }
    
    let name: String = "Hypnotism"
    let icon: Icon = IconSet.Skill.handMagic
    let cost: Int = 3
    var unlocked: Bool = false
    
    /// The `Quelling` instance defining the incapacitating effect of the skill.
    ///
    static let quelling = Quelling(breakOnDamage: true, makeVulnerable: true, duration: 15.0)
    
    func descriptionFor(entity: Entity) -> String {
        let duration = Int((HypnotismSkill.quelling.duration!).rounded())
        return """
        Casts a spell that prevents the selected target from taking any actions.
        Hypnotism cannot affect more than one target at the same time, and no more than once every \
        \(duration) seconds.
        Lasts \(duration) seconds.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("HypnotismSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("HypnotismSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Hypnotism(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
}

/// The struct defining the Hypnotism spell.
///
fileprivate struct Hypnotism {
    
    /// The `Touch` type that defines the effect of the spell.
    ///
    private class HypnotismTouch: Touch {
        
        let isHostile: Bool = true
        let range: CGFloat = 525.0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = nil
        
        /// The condition that the spell applies.
        ///
        let condition: HypnotismCondition
        
        /// Creates a new instance from the given entity.
        ///
        /// - Note: A new `HypnotismCondition` is created for every use to prevent the `ConditionComponent`
        ///   from resetting the condition's timer (due to `isExclusive` property being `true`), thus
        ///   forcing it to run for the full duration, as expected.
        ///
        /// - Parameter entity: The entity that will cast the spell.
        ///
        init(entity: Entity) {
            condition = HypnotismCondition(source: entity)
        }
        
        func didTouch(target: Entity, source: Entity?) {
            Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: nil, conditions: [condition])
        }
    }
    
    /// The `Spell` instance to use when casting the spell.
    ///
    let spell: Spell
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        let touch = HypnotismTouch(entity: entity)
        spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, touch.duration, 0.5))
    }
}
