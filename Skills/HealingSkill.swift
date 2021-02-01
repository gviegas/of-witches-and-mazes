//
//  HealingSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines a `Skill` type that can heal.
///
protocol HealingSkill: Skill {
    
    /// Computes the skill's healing for the given entity.
    ///
    /// - Parameter entity: The entity for which the skill's healing must be computed.
    /// - Returns: A new `Healing` instance representing the skill's damage.
    ///
    func healingFor(entity: Entity) -> Healing
}
