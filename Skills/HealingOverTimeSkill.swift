//
//  HealingOverTimeSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines a `Skill` type that causes healing over time.
///
protocol HealingOverTimeSkill: Skill {
    
    /// Computes the skill's healing over time for the given entity.
    ///
    /// - Parameter entity: The entity for which the skill's healing over time must be computed.
    /// - Returns: A new `HealingOverTimeCondition` instance representing the skill's healing over time.
    ///
    func healingOverTimeFor(entity: Entity) -> HealingOverTimeCondition
}
