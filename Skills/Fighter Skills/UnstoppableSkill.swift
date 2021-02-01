//
//  UnstoppableSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/21/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that makes the entity immune to hindering effects.
///
class UnstoppableSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.faceBloody.imageName]
    }
    
    let name: String = "Unstoppable"
    let icon: Icon = IconSet.Skill.faceBloody
    let cost: Int = 10
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return "Grants immunity to slow effects."
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let immunityComponent = entity.component(ofType: ImmunityComponent.self) else {
            fatalError("UnstoppableSkill can only be unlocked by an entity that has an ImmunityComponent")
        }
        
        immunityComponent.immunities.insert(.hampering)
    }
}
