//
//  WeaponMasterySkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that increases physical damage caused.
///
class WeaponMasterySkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.swordAndBow.imageName]
    }
    
    let name: String = "Weapon Mastery"
    let icon: Icon = IconSet.Skill.swordAndBow
    let cost: Int = 1
    var unlocked: Bool = false
    
    /// The physical damage bonus that the skill provides.
    ///
    private let damageBonus = 0.1
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases physical damage by \(Int((damageBonus * 100.0).rounded()))%.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self) else {
            fatalError("WeaponMasterySkill can only be unlocked on an entity that has a DamageAdjustmentComponent")
        }
        
        damageAdjustmentComponent.modifyDamageCausedFor(type: .physical, by: damageBonus)
    }
}
