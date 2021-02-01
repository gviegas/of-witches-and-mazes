//
//  CoupDeGraceSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that provides an attack capable of causing extra damage to wounded targets.
///
class CoupDeGraceSkill: UsableSkill, WaitTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.swordGrip.imageName]
    }
    
    let name: String = "Coup de Grâce"
    let icon: Icon = IconSet.Skill.swordGrip
    let cost: Int = 5
    var unlocked: Bool = false
    var waitTime: TimeInterval = 3.0
    
    /// The damage bonus that the skill provides.
    ///
    private let damageBonus = 1.0
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Executes an attack with the equipped melee weapon that causes \
        \(Int((damageBonus * 100.0).rounded()))% more damage to wounded targets.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("CoupDeGraceSkill can only be used by an entity that has an EquipmentComponent")
        }
        guard let attackComponent = entity.component(ofType: AttackComponent.self) else {
            fatalError("CoupDeGraceSkill can only be used by an entity that has a AttackComponent")
        }
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("CoupDeGraceSkill can only be used by an entity that has a StateComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("CoupDeGraceSkill can only be used by an entity that has a SkillComponent")
        }
        
        guard let item = equipmentComponent.itemOf(category: .meleeWeapon) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No melee weapon equipped")
                scene.presentNote(note)
            }
            return
        }
        
        let damage = (item as! DamageItem).damage
        let attack = Attack(medium: .melee, damage: damage,
                            reach: 48.0, broadness: 64.0,
                            delay: 0.15, duration: 0.1, conclusion: 0.15,
                            conditions: nil, sfx: SoundFXSet.FX.rive)
        attackComponent.attack = attack
        entity.addComponent(FinishingStrikeComponent(damageBonus: damageBonus, isSelfRemovable: true))
        stateComponent.enter(namedState: .attack)
        skillComponent.triggerSkillWaitTime(self)
    }
}
