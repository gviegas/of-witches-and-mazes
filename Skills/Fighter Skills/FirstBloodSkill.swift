//
//  FirstBloodSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that provides damage bonus against undamaged targets.
///
class FirstBloodSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.swordBloody.imageName]
    }
    
    let name: String = "First Blood"
    let icon: Icon = IconSet.Skill.swordBloody
    let cost: Int = 5
    var unlocked: Bool = false
    
    /// The damage bonus that the skill provides.
    ///
    private let damageBonus = 0.25
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Targets at full health take \(Int((damageBonus * 100.0).rounded()))% more damage.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(FirstStrikeComponent(damageBonus: damageBonus))
    }
}
