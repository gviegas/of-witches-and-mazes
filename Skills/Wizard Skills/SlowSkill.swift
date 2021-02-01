//
//  SlowSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Slow spell.
///
class SlowSkill: UsableSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.spellTwisting.imageName]
    }
    
    let name: String = "Slow"
    let icon: Icon = IconSet.Skill.spellTwisting
    let cost: Int = 7
    var unlocked: Bool = false
    
    /// The condition that the spell applies.
    ///
    /// - Note: Using a single `HamperCondition` instance allows for the condition's timer to be reset
    ///   when casting the spell on already affected targets.
    ///
    private let condition = HamperCondition(slowFactor: 0.65, isExclusive: true, isResettable: false,
                                            duration: 10.0, source: nil, color: nil,
                                            sfx: SoundFXSet.FX.conjurationHit)
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that reduces the movement speed of the selected target by \
        \(Int((condition.slowFactor * 100.0).rounded()))%.
        Lasts \(Int((condition.duration!).rounded())) seconds.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("SlowSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("SlowSkill can only be used by an entity that has a CastComponent")
        }
        
        condition.source = entity
        castComponent.spell = Slow(condition: condition).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
}

/// The struct representing the Slow spell.
///
fileprivate struct Slow {
    
    /// The `Touch` type that defines the effect of the spell.
    ///
    private class SlowTouch: Touch {
        
        let isHostile: Bool = true
        let range: CGFloat = 525.0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = nil
        
        /// The condition representing the Slow effect.
        ///
        private let condition: HamperCondition
        
        /// Creates a new instance from the given condition.
        ///
        /// - Parameter condition: The condition representing the Slow effect.
        ///
        init(condition: HamperCondition) {
            self.condition = condition
        }
        
        func didTouch(target: Entity, source: Entity?) {
            Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: nil, conditions: [condition])
        }
    }
    
    /// The `Spell` instance to use when casting the spell.
    ///
    let spell: Spell
    
    /// Creates a new instance from the given condition.
    ///
    /// - Parameter condition: The condition representing the Slow effect.
    ///
    init(condition: HamperCondition) {
        let touch = SlowTouch(condition: condition)
        spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, touch.duration, 0.5))
    }
}
