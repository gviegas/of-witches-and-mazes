//
//  UpdateNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `SKNode` subclass for specialized nodes that require continual update.
///
class UpdateNode: SKNode {
    
    /// Performs update.
    ///
    /// - Parameter seconds: The time since last update.
    ///
    func update(deltaTime seconds: TimeInterval) {
        
    }
    
    /// Performs termination.
    ///
    /// This method is intended to be called when the node is about to be deinitialized.
    /// Nodes that have been terminated should be considered invalid and no longer updated.
    ///
    func terminate() {
        
    }
}
