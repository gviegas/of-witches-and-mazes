//
//  SacrificeSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Inflict Wounds spell.
///
class SacrificeSkill: UsableSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.faceHoly.imageName]
    }
    
    let name: String = "Sacrifice"
    let icon: Icon = IconSet.Skill.faceHoly
    let cost: Int = 7
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that inflicts damage equal to \(Int((Sacrifice.damagePercentage * 100.0).rounded()))% \
        of the caster's current health points to itself and to the selected target.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("SacrificeSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("SacrificeSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Sacrifice(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
}

/// The struct defining the Sacrifice spell.
///
fileprivate struct Sacrifice {
    
    /// The `Touch` type that defines the effect of the spell.
    ///
    private class SacrificeTouch: Touch {
        
        let isHostile: Bool = true
        let range: CGFloat = 105.0
        let delay: TimeInterval = 0
        let duration: TimeInterval = 0
        let conclusion: TimeInterval = 0
        let animation: Animation? = nil
        let sfx: SoundFX? = SoundFXSet.Voice.femaleCleric
        
        /// The damage applied by the effect.
        ///
        let damage: Damage
        
        /// Creates a new instance from the given entity.
        ///
        /// - Parameter entity: The entity that will cast the spell.
        ///
        init(entity: Entity) {
            guard let healthComponent = entity.component(ofType: HealthComponent.self) else {
                fatalError("Sacrifice can only be used by an entity that has a HealthComponent")
            }
            
            let absoluteDamage = Int((Double(healthComponent.currentHP) * Sacrifice.damagePercentage).rounded())
            damage = Damage(baseDamage: absoluteDamage...absoluteDamage, modifiers: [:], type: .spiritual, sfx: nil)
            damage.createDamageSnapshot(from: entity, using: .spell)
        }
        
        func didTouch(target: Entity, source: Entity?) {
            Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: damage,
                                         conditions: nil, unavoidable: true)
            
            guard let source = source else { return }
            
            Combat.carryOutHostileAction(using: .spell, on: source, as: nil, damage: damage,
                                         conditions: nil, unavoidable: true)
        }
    }
    
    /// The percentage of the source's current health points applied by the spell as damage (normalized).
    ///
    static let damagePercentage = 0.85
    
    /// The `Spell` instance to use when casting the spell.
    ///
    let spell: Spell
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        let touch = SacrificeTouch(entity: entity)
        spell = Spell(kind: .targetTouch, effect: touch, castTime: (0.75, 0, 0.5))
    }
}
