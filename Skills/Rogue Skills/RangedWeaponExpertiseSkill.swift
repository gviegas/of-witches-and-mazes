//
//  RangedWeaponExpertiseSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type tha increases critical hit chance with ranged weapons.
///
class RangedWeaponExpertiseSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.target.imageName]
    }
    
    var name: String = "Ranged Weapon Expertise"
    var icon: Icon = IconSet.Skill.target
    var cost: Int = 5
    var unlocked: Bool = false
    
    /// The ranged critical hit bonus that the skill provides.
    ///
    private let critBonus = 0.1
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases critical hit chance with ranged weapons by \(Int((critBonus * 100.0).rounded()))%.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let criticalHitComponent = entity.component(ofType: CriticalHitComponent.self) else {
            fatalError("RangedWeaponExpertiseSkill can only be unlocked on an entity that has a CriticalHitComponent")
        }
        
        criticalHitComponent.modifyCriticalChanceFor(medium: .ranged, by: critBonus)
    }
}
