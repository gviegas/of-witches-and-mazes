//
//  DamageOverTimeSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines a `Skill` type that causes damage over time.
///
protocol DamageOverTimeSkill: Skill {
    
    /// Computes the skill's damage over time for the given entity.
    ///
    /// - Parameter entity: The entity for which the skill's damage over time must be computed.
    /// - Returns: A new `DamageOverTimeCondition` instance representing the skill's damage over time.
    ///
    func damageOverTimeFor(entity: Entity) -> DamageOverTimeCondition
}
