//
//  WaitTimeSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that provides a `Skill` type with a wait time, which defines the time to wait
/// before a skill effect can be reapplied.
///
protocol WaitTimeSkill: Skill {
    
    /// The wait time.
    ///
    var waitTime: TimeInterval { get }
}
