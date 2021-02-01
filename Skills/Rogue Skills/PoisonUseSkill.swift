//
//  PoisonUseSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that causes physical attacks to apply `PoisonCondition` on targets.
///
class PoisonUseSkill: PassiveSkill, DamageOverTimeSkill, TextureUser {

    static var textureNames: Set<String> {
        return [IconSet.Skill.poison.imageName]
    }
    
    let name: String = "Poison Use"
    let icon: Icon = IconSet.Skill.poison
    let cost: Int = 2
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Causing damage with physical attacks applies poison to the victim.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(PoisonComponent())
    }
    
    func damageOverTimeFor(entity: Entity) -> DamageOverTimeCondition {
        return PoisonComponent.poisonFor(entity: entity)
    }
}
