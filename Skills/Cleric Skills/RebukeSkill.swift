//
//  RebukeSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that enables an entity to damage enemies whose attacks it absorbed.
///
class RebukeSkill: PassiveSkill, DamageSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.reflect.imageName]
    }
    
    let name: String = "Rebuke"
    let icon: Icon = IconSet.Skill.reflect
    let cost: Int = 5
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Inflicts damage to enemies whose attacks are absorbed.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(RetributionComponent())
    }
    
    func damageFor(entity: Entity) -> Damage {
        return RetributionComponent.damageFor(entity: entity)
    }
}
