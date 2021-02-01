//
//  SneakAttackSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to execute a powerful attack when `StealthSkill` is active.
///
class SneakAttackSkill: UsableSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.faceAndDagger.imageName]
    }
    
    let name: String = "Sneak Attack"
    let icon: Icon = IconSet.Skill.faceAndDagger
    let cost: Int = 7
    var unlocked: Bool = false
    
    /// The multiplier applied by the skill on the weapon's base damage.
    ///
    private let damageMultiplier = 4.5
    
    /// The skill damage.
    ///
    /// - Note: This property must only be accessed after calling `didUse(onEntity:).`
    ///
    var damage: Damage!
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Executes a powerful attack with the equipped melee weapon, causing \(damageMultiplier) \
        times the weapon's base damage.
        This attack cannot be defended.
        Can only be used when Stealth is active.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("SneakAttackSkill can only be used by an entity that has a StateComponent")
        }
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("SneakAttackSkill can only be used by an entity that has an EquipmentComponent")
        }
        
        guard stateComponent.currentState is RogueStealthState else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Requires Stealth")
                scene.presentNote(note)
            }
            return
        }
        
        guard let item = equipmentComponent.itemOf(category: .meleeWeapon) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No melee weapon equipped")
                scene.presentNote(note)
            }
            return
        }
        
        let normalDamage = (item as! DamageItem).damage
        let lowerBound = Int((Double(normalDamage.baseDamage.lowerBound) * damageMultiplier).rounded())
        let upperBound = Int((Double(normalDamage.baseDamage.upperBound) * damageMultiplier).rounded())
        damage = Damage(baseDamage: lowerBound...upperBound, modifiers: normalDamage.modifiers,
                        type: normalDamage.type, sfx: normalDamage.sfx)
        stateComponent.enter(stateClass: RogueSneakAttackState.self)
    }
}
