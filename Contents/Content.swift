//
//  Content.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An enum defining the available types of content.
///
enum ContentType: Hashable {
    case destructible
    case indestructible
    case trap
    case treasure
    case merchant
    case companion
    case enemy
    case elite
    case rare
    case protagonist
    case exit
    case other(String)
}

/// A class that represents a single piece of game content (i.e., an entity or node), intended
/// to be used by `Level` types.
///
class Content {
    
    /// The optional node instance, only used when `entity` is `nil`.
    ///
    private let _node: SKNode!
    
    /// The content's type.
    ///
    let type: ContentType
    
    /// The flag stating whether the position of the content can change.
    ///
    let isDynamic: Bool
    
    /// The flag stating whether the content must be considered an obstacle to be avoided.
    ///
    /// - Note: For purposes of path finding, only static contents will be considered. Thus, if the content
    ///   has its `isDynamic` flag set to `true`, setting this property won't affect path finding.
    ///
    let isObstacle: Bool
    
    /// The content's entity.
    ///
    let entity: Entity?
    
    /// The content's node.
    ///
    var node: SKNode {
        if let entity = entity {
            guard let component = entity.component(ofType: NodeComponent.self) else {
                fatalError("An entity assigned to Content no longer has a NodeComponent")
            }
            return component.node
        }
        return _node
    }
    
    /// The content's size.
    ///
    var size: CGSize {
        if let entity = entity {
            guard let component = entity.component(ofType: SpriteComponent.self) else {
                fatalError("An entity assigned to Content no longer has a SpriteComponent")
            }
            return component.size
        }
        return (_node as? SKSpriteNode)?.size ?? _node.calculateAccumulatedFrame().size
    }
    
    /// The content's position.
    ///
    /// - Note: This property can be used to correctly position the entity relative to its `PhysicsComponent` -
    ///   the `PhysicsShape`'s center will be subtracted from the provided point to compute the final position.
    ///   If the entity is `nil` or does not have a `PhysicsComponent`, setting this property is no different
    ///   than setting the node's position directly.
    ///
    var position: CGPoint {
        get {
            return entity?.component(ofType: PhysicsComponent.self)?.position ?? node.position
        }
        set {
            if let entity = entity, let component = entity.component(ofType: PhysicsComponent.self)  {
                let physicsCenter: CGPoint
                switch component.physicsShape {
                case .circle(_, let center):
                    physicsCenter = center
                case .rectangle(_, let center):
                    physicsCenter = center
                }
                node.position = CGPoint(x: newValue.x - physicsCenter.x, y: newValue.y - physicsCenter.y)
            } else {
                node.position = newValue
            }
        }
    }
    
    /// Creates a new instance from an entity.
    ///
    /// - Parameters:
    ///   - type: The type of the content.
    ///   - isDynamic: A flag that defines if the content is dynamic, i.e., if it can change positions.
    ///   - isObstacle: A flag that defines if the content must be considered an obstacle to be avoided.
    ///   - entity: The entity that represents the content.
    ///
    init(type: ContentType, isDynamic: Bool, isObstacle: Bool, entity: Entity) {
        guard entity.component(ofType: SpriteComponent.self) != nil else {
            fatalError("An entity assigned to Content must have a SpriteComponent")
        }
        
        self._node = nil
        self.type = type
        self.isDynamic = isDynamic
        self.isObstacle = isObstacle
        self.entity = entity
    }
    
    /// Creates a new instance from a node.
    ///
    /// - Parameters:
    ///   - type: The type of the content.
    ///   - isDynamic: A flag that defines if the content is dynamic, i.e., if it can change positions.
    ///   - isObstacle: A flag that defines if the content must be considered an obstacle to be avoided.
    ///   - node: The node that represents the content.
    ///
    init(type: ContentType, isDynamic: Bool, isObstacle: Bool, node: SKNode) {
        self._node = node
        self.type = type
        self.isDynamic = isDynamic
        self.isObstacle = isObstacle
        self.entity = nil
    }
}
