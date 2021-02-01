//
//  DashSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/21/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to dash in a straight line, damaging
/// enemies along the way.
///
class DashSkill: UsableSkill, WaitTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.swordDashing.imageName]
    }
    
    let name: String = "Dash"
    let icon: Icon = IconSet.Skill.swordDashing
    let cost: Int = 7
    var unlocked: Bool = false
    var waitTime: TimeInterval = 5.0
    
    /// The condition that the skill applies.
    ///
    static let condition = QuellCondition(quelling: Quelling(breakOnDamage: false,
                                                             makeVulnerable: true,
                                                             duration: 1.5),
                                          source: nil, color: nil, sfx: nil)
    
    /// The skill damage.
    ///
    /// - Note: This property must only be accessed after calling `didUse(onEntity:).`
    ///
    var damage: Damage!
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Dashes forward, damaging any enemies in the way and incapacitating them for \
        \(DashSkill.condition.duration!) seconds.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("DashSkill can only be used by an entity that has an EquipmentComponent")
        }
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("DashSkill can only be used by an entity that has a StateComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("DashSkill can only be used by an entity that has a SkillComponent")
        }
        
        guard let item = equipmentComponent.itemOf(category: .meleeWeapon) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No melee weapon equipped")
                scene.presentNote(note)
            }
            return
        }
        
        damage = (item as! DamageItem).damage
        stateComponent.enter(stateClass: FighterDashState.self)
        skillComponent.triggerSkillWaitTime(self)
    }
}
