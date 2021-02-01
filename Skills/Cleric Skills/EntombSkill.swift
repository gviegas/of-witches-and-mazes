//
//  EntombSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Entomb spell.
///
class EntombSkill: UsableSkill, DamageSkill, WaitTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.coffin.imageName]
    }
    
    let name: String = "Entomb"
    let icon: Icon = IconSet.Skill.coffin
    let cost: Int = 10
    var unlocked: Bool = false
    var waitTime: TimeInterval = 15.0
    
    /// The `Quelling` instance defining the incapacitating effect of the skill.
    ///
    static let quelling = Quelling(breakOnDamage: false, makeVulnerable: true, duration: 6.0)
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that damages and incapacitates the selected target.
        Lasts \(Int(EntombSkill.quelling.duration!.rounded())) seconds.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("EntombSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("EntombSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Entomb(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
    
    func damageFor(entity: Entity) -> Damage {
        return Entomb.damageFor(entity: entity)
    }
}

/// The struct defining the Entomb spell.
///
fileprivate struct Entomb {
    
    /// The `Touch` type that defines the effect of the spell.
    ///
    private class EntombTouch: Touch {
        
        let isHostile: Bool = true
        let range: CGFloat = 420.0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = nil
        
        /// The quell condition applied by the effect.
        ///
        let condition: QuellCondition
        
        /// The damage applied by the effect.
        ///
        let damage: Damage
        
        /// Creates a new instance from the given entity.
        ///
        /// - Parameter entity: The entity that will cast the spell.
        ///
        init(entity: Entity) {
            condition = EntombCondition(source: entity)
            damage = Entomb.damageFor(entity: entity)
        }
        
        func didTouch(target: Entity, source: Entity?) {
            if let skillComponent = source?.component(ofType: SkillComponent.self) {
                if let skill = skillComponent.skillOfClass(EntombSkill.self) as? WaitTimeSkill {
                    skillComponent.triggerSkillWaitTime(skill)
                }
            }
            Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: damage,
                                         conditions: [condition])
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
        let touch = EntombTouch(entity: entity)
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
        
        return Damage(scale: 3.0, ratio: 0.2, level: progressionComponent.levelOfExperience,
                      modifiers: [.faith: 0.7], type: .spiritual, sfx: nil)
    }
}
