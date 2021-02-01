//
//  TranscendenceSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that makes an entity immune to poison and curse conditions.
///
class TranscendenceSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.angel.imageName]
    }
    
    let name: String = "Transcendence"
    let icon: Icon = IconSet.Skill.angel
    let cost: Int = 9
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Grants immunity to poison and curse.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let immunityComponent = entity.component(ofType: ImmunityComponent.self) else {
            fatalError("TranscendenceSkill can only be unlocked by an entity that has an ImmunityComponent")
        }
        
        immunityComponent.immunities.insert(.poison)
        immunityComponent.immunities.insert(.curse)
    }
}
