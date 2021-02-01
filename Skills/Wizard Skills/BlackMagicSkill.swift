//
//  BlackMagicSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that causes magical damage to weaken enemies.
///
class BlackMagicSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.symbolMagic.imageName]
    }
    
    let name: String = "Black Magic"
    let icon: Icon = IconSet.Skill.symbolMagic
    let cost: Int = 4
    var unlocked: Bool = false
    
    /// The weaken condition representing the skill effect.
    ///
    private let condition = WeakenCondition(damageCausedReduction: 0.3, isExclusive: true, isResettable: false,
                                            duration: 10.0, source: nil, color: nil, sfx: nil)
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Enemies damaged by the wizard's spells will cause \
        \(Int((condition.damageCausedReduction * 100.0).rounded()))% less damage.
        Lasts \(Int(condition.duration!)) seconds.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(EnfeeblementComponent(weakenCondition: condition))
    }
}
