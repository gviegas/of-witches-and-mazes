//
//  ShatterSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UsableSkill` that enables an entity to cast the Shatter spell.
///
class ShatterSkill: UsableSkill, DamageSkill, WaitTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.spellSphere.imageName]
    }
    
    let name: String = "Shatter"
    let icon: Icon = IconSet.Skill.spellSphere
    let cost: Int = 8
    var unlocked: Bool = false
    var waitTime: TimeInterval = 10.0
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that damages everything around the caster.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("ShatterSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("ShatterSkill can only be used by an entity that has a CastComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("ShatterSkill can only be used by an entity that has a SkillComponent")
        }
        
        castComponent.spell = Shatter(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
        skillComponent.triggerSkillWaitTime(self)
    }
    
    func damageFor(entity: Entity) -> Damage {
        return Shatter.damageFor(entity: entity)
    }
}

/// The struct defining the Shatter spell.
///
fileprivate struct Shatter {
    
    /// The `Influence` type that defines the effect of the spell.
    ///
    private class ShatterInfluence: Influence {
        
        let interaction: Interaction = .protagonistEffect
        let radius: CGFloat = 420.0
        let range: CGFloat = 0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0.1
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = SoundFXSet.FX.spellHit
        
        /// The damage to apply to affected targets.
        ///
        let damage: Damage
        
        /// The caster entity.
        ///
        weak var entity: Entity?
        
        /// Creates a new instance from the given entity.
        ///
        /// - Parameter entity: The entity that will cast the spell.
        ///
        init(entity: Entity) {
            self.entity = entity
            damage = Shatter.damageFor(entity: entity)
        }
        
        func didInfluence(node: SKNode, source: Entity?) {
            guard let target = node.entity as? Entity else { return }
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
        let influence = ShatterInfluence(entity: entity)
        let duration = influence.delay + influence.duration + influence.conclusion
        spell = Spell(kind: .localInfluence, effect: influence, castTime: (0.5, duration, 0.5))
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
        
        return Damage(scale: 1.45, ratio: 0.25, level: progressionComponent.levelOfExperience,
                      modifiers: [.intellect: 0.5], type: .magical, sfx: SoundFXSet.FX.crushing)
    }
}
