//
//  IntimidateSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that causes successful melee attacks to intimidate the target, making them vulnerable.
///
class IntimidateSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.intimidatingStance.imageName]
    }
    
    let name: String = "Intimidate"
    let icon: Icon = IconSet.Skill.intimidatingStance
    let cost: Int = 10
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Causing damage to enemies makes them unable to defend or resist further attacks.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let intimidationComponent = entity.component(ofType: IntimidationComponent.self) else {
            fatalError("IntimidateSkill can only be unlocked on an entity tha has an IntimidationComponent")
        }
        
        intimidationComponent.canIntimidate = true
    }
}
