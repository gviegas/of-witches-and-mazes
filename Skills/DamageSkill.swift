//
//  DamageSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines a `Skill` type that causes damage.
///
protocol DamageSkill: Skill {
    
    /// Computes the skill's damage for the given entity.
    ///
    /// - Parameter entity: The entity for which the skill's damage must be computed.
    /// - Returns: A new `Damage` instance representing the skill's damage.
    ///
    func damageFor(entity: Entity) -> Damage
}
