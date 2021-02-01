//
//  CripplingThrowSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to throw a dagger which cripples the target movement.
///
class CripplingThrowSkill: UsableSkill, WaitTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.daggerPiercing.imageName]
    }
    
    /// The crippling condition that the skill applies.
    ///
    let condition = HamperCondition(slowFactor: 0.7, isExclusive: true, isResettable: true, duration: 8.0,
                                    source: nil, color: nil, sfx: nil)
    
    let name: String = "Crippling Throw"
    let icon: Icon = IconSet.Skill.daggerPiercing
    let cost: Int = 3
    var unlocked: Bool = false
    var waitTime: TimeInterval = 6.0
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Throws the equipped dagger at the target, reducing its movement speed by \
        \(Int((condition.slowFactor * 100.0).rounded()))%.
        Lasts \(Int(condition.duration!.rounded())) seconds.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("CripplingThrowSkill can only be used by an entity that has an EquipmentComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("CripplingThrowSkill can only be used by an entity that has a SkillComponent")
        }
        
        guard let daggerItem = equipmentComponent.itemOf(category: .throwingWeapon) as? DaggerItem else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No dagger equipped")
                scene.presentNote(note)
            }
            return
        }
        
        daggerItem.didUseCripplingThrowSkill(onEntity: entity)
        skillComponent.triggerSkillWaitTime(self)
    }
}
