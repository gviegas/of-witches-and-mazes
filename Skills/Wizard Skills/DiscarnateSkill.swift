//
//  DiscarnateSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that enables an entity to become a Wraith on death.
///
class DiscarnateSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.skullMagic.imageName]
    }
    
    let name: String = "Discarnate"
    let icon: Icon = IconSet.Skill.skullMagic
    let cost: Int = 10
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Becomes a wraith on death.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(WraithComponent(wraithStateClass: WizardDiscarnateState.self))
    }
}
