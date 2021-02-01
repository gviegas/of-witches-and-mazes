//
//  CureWoundsSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Cure Wounds spell.
///
class CureWoundsSkill: UsableSkill, HealingSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.powerSphere.imageName]
    }
    
    let name: String = "Cure Wounds"
    let icon: Icon = IconSet.Skill.powerSphere
    let cost: Int = 0
    var unlocked: Bool = true
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that heals the selected target.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("CureWoundsSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("CureWoundsSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = CureWounds(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
    
    func healingFor(entity: Entity) -> Healing {
        return CureWounds.healingFor(entity: entity)
    }
}

/// The struct defining the Cure Wounds spell.
///
fileprivate struct CureWounds {
    
    /// The `Touch` type that defines the effect of the spell.
    ///
    private class CureWoundsTouch: Touch {
        
        let isHostile: Bool = false
        let range: CGFloat = 420.0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = nil
        
        /// The healing applied by the effect.
        ///
        let healing: Healing
        
        /// Creates a new instance from the given entity.
        ///
        /// - Parameter entity: The entity that will cast the spell.
        ///
        init(entity: Entity) {
            healing = CureWounds.healingFor(entity: entity)
        }
        
        func didTouch(target: Entity, source: Entity?) {
            Combat.carryOutFriendlyAction(using: .spell, on: target, as: source, healing: healing, conditions: nil)
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
        guard let targetComponent = entity.component(ofType: TargetComponent.self) else {
            fatalError("CureWounds can only be used by an entity that has a TargetComponent")
        }
        guard let groupComponent = entity.component(ofType: GroupComponent.self) else {
            fatalError("CureWounds can only be used by an entity that has a GroupComponent")
        }
        
        let kind: SpellKind
        if let target = targetComponent.source, groupComponent.isFriendly(towards: target) {
            kind = .targetTouch
        } else {
            kind = .localTouch
        }
        let touch = CureWoundsTouch(entity: entity)
        spell = Spell(kind: kind, effect: touch, castTime: (0.75, 0, 0.5))
    }
    
    /// Computes the `Healing` instance used by the spell.
    ///
    /// - Parameter entity: The entity that will use the spell.
    /// - Returns: The spell's `Healing`.
    ///
    static func healingFor(entity: Entity) -> Healing {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("`healingFor(entity:)` requires an entity that has a ProgressionComponent")
        }
        
        return Healing(scale: 1.25, ratio: 0.2, level: progressionComponent.levelOfExperience,
                       modifiers: [.faith: 0.5], sfx: SoundFXSet.FX.liquid)
    }
}
