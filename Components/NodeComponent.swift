//
//  NodeComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/22/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that represents the main node of an entity.
///
/// This component provides the node that represents the entity itself. It must be added
/// to a scene graph when the entity is to be draw.
///
class NodeComponent: Component {
    
    /// The node.
    ///
    let node = SKNode()
    
    override func didAddToEntity() {
        node.entity = entity
        if let entity = entity as? Entity {
            node.name = "\(entity.name).\(entity.identifier)"
        }
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        node.name = nil
    }
}
