//
//  AuraOfCastigationSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that provides an entity with an aura that damages enemies.
///
class AuraOfCastigationSkill: PassiveSkill, DamageOverTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.auraHoly.imageName]
    }
    
    let name: String = "Aura of Castigation"
    let icon: Icon = IconSet.Skill.auraHoly
    let cost: Int = 8
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Continuously damages nearby enemies.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        if entity.component(ofType: AuraComponent.self) == nil {
            entity.addComponent(AuraComponent(interaction: .protagonistEffect))
        }
        entity.addComponent(CastigationComponent())
    }
    
    func damageOverTimeFor(entity: Entity) -> DamageOverTimeCondition {
        return CastigationCondition(source: entity)
    }
}
