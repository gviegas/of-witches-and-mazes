//
//  OverpowerSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that causes attackers to be incapacitated if their attacks are
/// successfully defended by the entity.
///
class OverpowerSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.shieldDefending.imageName]
    }
    
    let name: String = "Overpower"
    let icon: Icon = IconSet.Skill.shieldDefending
    let cost: Int = 8
    var unlocked: Bool = false
    
    /// The duration of the incapacitating effect.
    ///
    private let duration: TimeInterval = 2.0
    
    func descriptionFor(entity: Entity) -> String {
        return """
        A successful defense will incapacitate the attacker for \(Int(duration.rounded())) seconds.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        entity.addComponent(StunningDefenseComponent(duration: duration))
    }
}
