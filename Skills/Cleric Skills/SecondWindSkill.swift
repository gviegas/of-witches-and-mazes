//
//  SecondWindSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that applies a healing over time condition when the entity is at low health.
///
class SecondWindSkill: PassiveSkill, HealingOverTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.light.imageName]
    }
    
    let name: String = "Second Wind"
    let icon: Icon = IconSet.Skill.light
    let cost: Int = 4
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Applies healing over time at low health.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(SecondWindComponent())
    }
    
    func healingOverTimeFor(entity: Entity) -> HealingOverTimeCondition {
        return SecondWindCondition(source: nil)
    }
}
