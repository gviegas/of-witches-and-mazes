//
//  FanaticismSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that increases damage caused and reduces damage taken.
///
class FanaticismSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.crosses.imageName]
    }
    
    let name: String = "Fanaticism"
    let icon: Icon = IconSet.Skill.crosses
    let cost: Int = 3
    var unlocked: Bool = false
    
    /// The damage caused bonus that the skill provides.
    ///
    private let damageCausedBonus = 0.1
    
    /// The damage taken reduction that the skill provides.
    ///
    private let damageTakenReduction = 0.1
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases all damage caused by \(Int((damageCausedBonus * 100.0).rounded()))% and reduces \
        all damage taken by \(Int((damageTakenReduction * 100.0).rounded()))%.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self) else {
            fatalError("FanaticismSkill can only be unlocked on an entity that has a DamageAdjustmentComponent")
        }
        
        damageAdjustmentComponent.modifyDamageCaused(by: damageCausedBonus)
        damageAdjustmentComponent.modifyDamageTaken(by: -damageTakenReduction)
    }
}
