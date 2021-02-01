//
//  PassiveSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines a `Skill` type that applies a passive effect when unlocked.
///
protocol PassiveSkill: Skill {
    
    /// Informs that an entity has unlocked the skill.
    ///
    /// - Parameter entity: The entity that unlocked the skill.
    ///
    func didUnlock(onEntity entity: Entity)
}
