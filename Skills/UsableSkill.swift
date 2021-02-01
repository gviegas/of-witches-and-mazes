//
//  UsableSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines a `Skill` type that can be used by an entity.
///
protocol UsableSkill: Skill {
    
    /// Informs that an entity has used the skill.
    ///
    /// - Parameter entity: The entity that used the skill.
    ///
    func didUse(onEntity entity: Entity)
}
