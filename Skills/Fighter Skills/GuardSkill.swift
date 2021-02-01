//
//  GuardSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to guard against attacks.
///
class GuardSkill: UsableSkill, ActiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.swordGuarding.imageName]
    }
    
    let name: String = "Guard"
    let icon: Icon = IconSet.Skill.swordGuarding
    let cost: Int = 0
    var unlocked: Bool = true
    var isActive: Bool = false
    
    /// The condition representing the protection provided by the skill.
    ///
    static let protectionCondition = ProtectionCondition()
    
    func descriptionFor(entity: Entity) -> String {
        let bonus = (GuardSkill.protectionCondition.defenseBonus,
                     GuardSkill.protectionCondition.resistanceBonus)
        return """
        Increases defense by \(Int((bonus.0 * 100.0).rounded()))% and resistance by \
        \(Int((bonus.1 * 100.0).rounded()))%.
        Moving or performing any other action will cancel Guard.
        Lasts until cancelled.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("GuardSkill can only be used by an entity that has an EquipmentComponent")
        }
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GuardSkill can only be used by an entity that has a StateComponent")
        }
        
        guard let _ = equipmentComponent.itemOf(category: .meleeWeapon) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No melee weapon equipped")
                scene.presentNote(note)
            }
            return
        }
        
        stateComponent.enter(stateClass: FighterGuardState.self)
    }
}
