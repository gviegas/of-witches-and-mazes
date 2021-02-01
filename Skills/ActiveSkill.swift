//
//  ActiveSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/22/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that provides a `Skill` type with an activation flag, intended to be used by
/// non-instantaneous skills.
///
protocol ActiveSkill: Skill {
    
    /// The flag stating whether the skill is currently active.
    ///
    var isActive: Bool { get set }
}
