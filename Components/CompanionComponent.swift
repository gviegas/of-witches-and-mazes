//
//  CompanionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to own, or act as, a companion.
///
class CompanionComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a CompanionComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    /// The min/max distance to keep between the entity and the companion.
    ///
    var distance: ClosedRange<CGFloat> = 72.0...1024.0
    
    /// The current position of the companion.
    ///
    var position: CGPoint? {
        if let companion = companion {
            if let physicsComponent = companion.component(ofType: PhysicsComponent.self) {
                return physicsComponent.position
            } else if let nodeComponent = companion.component(ofType: NodeComponent.self) {
                return nodeComponent.node.position
            }
        }
        return nil
    }
    
    /// Checks if the current distance between entity and companion is equal or less
    /// than `distance.lowerBound`.
    ///
    var isClose: Bool? {
        guard let position = position else { return nil }
        
        let origin = physicsComponent.position
        let point = CGPoint(x: position.x - origin.x, y: position.y - origin.y)
        let length = (point.x * point.x + point.y * point.y).squareRoot()
        return distance.lowerBound >= length
    }
    
    /// Checks if the current distance between entity and companion is equal or greater
    /// than `distance.upperBound`.
    ///
    var isFar: Bool? {
        guard let position = position else { return nil }
        
        let origin = physicsComponent.position
        let point = CGPoint(x: position.x - origin.x, y: position.y - origin.y)
        let length = (point.x * point.x + point.y * point.y).squareRoot()
        return distance.upperBound <= length
    }
    
    /// The companion entity.
    ///
    /// For entities that act like masters, this property will hold a reference to
    /// the current follower. For follower entities (`Companion` types), this property
    /// will hold a reference to the current master.
    ///
    weak var companion: Entity?
}
