//
//  EntityState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/8/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The base class for all entity states.
///
class EntityState: GKState {
    
    /// The entity that owns the state.
    ///
    unowned var entity: Entity
    
    /// Creates a new instance for the given entity.
    ///
    /// - Parameter entity: The `Entity` instance that owns the state.
    ///
    required init(entity: Entity) {
        self.entity = entity
    }
}
