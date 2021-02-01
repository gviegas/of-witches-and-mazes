//
//  DefensiveCombatSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/21/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that improves the entity's defense.
///
class DefensiveCombatSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.swordParrying.imageName]
    }
    
    let name: String = "Defensive Combat"
    let icon: Icon = IconSet.Skill.swordParrying
    let cost: Int = 2
    var unlocked: Bool = false
    
    /// The defense bonus that the skill provides.
    ///
    private let defenseBonus = 0.2
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases defense by \(Int((defenseBonus * 100.0).rounded()))%.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let defenseComponent = entity.component(ofType: DefenseComponent.self) else {
            fatalError("DefensiveCombatSkill can only be unlocked on an entity that has a DefenseComponent")
        }
        
        defenseComponent.modifyDefense(by: defenseBonus)
    }
}
