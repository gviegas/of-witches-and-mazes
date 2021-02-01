//
//  InflictWoundsSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Inflict Wounds spell.
///
class InflictWoundsSkill: UsableSkill, DamageSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.powerDiamond.imageName]
    }
    
    let name: String = "Inflict Wounds"
    let icon: Icon = IconSet.Skill.powerDiamond
    let cost: Int = 1
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that damages the selected target.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("InflictWoundsSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("InflictWoundsSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = InflictWounds(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
    
    func damageFor(entity: Entity) -> Damage {
        return InflictWounds.damageFor(entity: entity)
    }
}

/// The struct defining the Inflict Wounds spell.
///
fileprivate struct InflictWounds {
    
    /// The `Touch` type that defines the effect of the spell.
    ///
    private class InflictWoundsTouch: Touch {
        
        let isHostile: Bool = true
        let range: CGFloat = 105.0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = nil
        
        /// The damage applied by the effect.
        ///
        let damage: Damage
        
        /// Creates a new instance from the given entity.
        ///
        /// - Parameter entity: The entity that will cast the spell.
        ///
        init(entity: Entity) {
            damage = InflictWounds.damageFor(entity: entity)
        }
        
        func didTouch(target: Entity, source: Entity?) {
            Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: damage, conditions: nil)
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
        let touch = InflictWoundsTouch(entity: entity)
        spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, 0, 0.5))
    }
    
    /// Computes the `Damage` instance used by the spell.
    ///
    /// - Parameter entity: The entity that will use the spell.
    /// - Returns: The spell's `Damage`.
    ///
    static func damageFor(entity: Entity) -> Damage {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("`damageFor(entity:)` requires an entity that has a ProgressionComponent")
        }
        
        return Damage(scale: 1.25, ratio: 0.2, level: progressionComponent.levelOfExperience,
                      modifiers: [.faith: 0.5], type: .spiritual, sfx: SoundFXSet.FX.darkHit)
    }
}
