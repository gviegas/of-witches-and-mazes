//
//  DestructiveMagicSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that increases magical damage caused.
///
class DestructiveMagicSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.spellColliding.imageName]
    }
    
    let name: String = "Destructive Magic"
    let icon: Icon = IconSet.Skill.spellColliding
    let cost: Int = 5
    var unlocked: Bool = false
    
    /// The magical damage bonus that the skill provides.
    ///
    private let damageBonus = 0.1
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases magical damage by \(Int((damageBonus * 100.0).rounded()))%.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        guard let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self) else {
            fatalError("DestructiveMagicSkill can only be unlocked on an entity that has a DamageAdjustmentComponent")
        }
        
        damageAdjustmentComponent.modifyDamageCausedFor(type: .magical, by: damageBonus)
    }
}
