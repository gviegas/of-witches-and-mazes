//
//  Skill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines the skill, a special power/ability for entities.
///
protocol Skill: AnyObject {
    
    /// The name of the skill.
    ///
    var name: String { get }
    
    /// The icon that represents the skill.
    ///
    var icon: Icon { get }
    
    /// The cost to unlock the skill.
    ///
    var cost: Int { get }
    
    /// The flag stating whether or not the skill has been unlocked.
    ///
    var unlocked: Bool { get set }
    
    /// Creates a textual description of the skill.
    ///
    /// - Parameter entity: The entity that owns the skill.
    /// - Returns: A `string` describing the skill.
    ///
    func descriptionFor(entity: Entity) -> String
}
