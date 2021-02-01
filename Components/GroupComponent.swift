//
//  GroupComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum defining the available groups for a `GroupComponent`.
///
enum Group {
    case protagonist, antagonist, neutral
    
    /// Checks if the group is hostile towards another one.
    ///
    /// - Parameter group: The group to check.
    /// - Returns: `true` if this group is hostile towards the given group, `false` otherwise.
    ///
    func isHostile(towards group: Group) -> Bool {
        switch self {
        case .protagonist:
            return group == .antagonist
        case .antagonist:
            return group == .protagonist
        case .neutral:
            return false
        }
    }
    
    /// Checks if the group is friendly towards another one.
    ///
    /// - Parameter group: The group to check.
    /// - Returns: `true` if this group is friendly towards the given group, `false` otherwise.
    ///
    func isFriendly(towards group: Group) -> Bool {
        switch self {
        case .neutral:
            return true
        default:
            return self == group
        }
    }
}

/// A component that places an entity in a specific group for purposes of hostility checks.
///
class GroupComponent: Component {
    
    /// The group.
    ///
    let group: Group
    
    /// Creates a new instance from the given group.
    ///
    /// - Parameter group: The group to which the entity must belong.
    ///
    init(group: Group) {
        self.group = group
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Checks if a given entity is meant to be treated as an enemy.
    ///
    /// - Parameter entity: The entity to check.
    /// - Returns: `true` if the component's entity is hostile towards the given entity, `false` otherwise.
    ///
    func isHostile(towards entity: Entity) -> Bool {
        guard let otherGroup = entity.component(ofType: GroupComponent.self)?.group else { return false }
        return group.isHostile(towards: otherGroup)
    }
    
    /// Checks if a given entity is meant to be treated as an ally.
    ///
    /// - Parameter entity: The entity to check.
    /// - Returns: `true` if the component's entity is friendly towards the given entity, `false` otherwise.
    ///
    func isFriendly(towards entity: Entity) -> Bool {
        guard let otherGroup = entity.component(ofType: GroupComponent.self)?.group else { return false }
        return group.isFriendly(towards: otherGroup)
    }
}
