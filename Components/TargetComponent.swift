//
//  TargetComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/5/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that defines target distance values.
///
enum TargetDistance: CGFloat {
    case short = 875.0
    case medium = 1750.0
    case long = 2625.0
}

/// A component that provides an entity with a dynamic target for its actions.
///
class TargetComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a TargetComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    /// The current target.
    ///
    var target: CGPoint? {
        if let source = source {
            if let physicsComponent = source.component(ofType: PhysicsComponent.self) {
                return physicsComponent.position
            } else if let nodeComponent = source.component(ofType: NodeComponent.self) {
                return nodeComponent.node.position
            }
        }
        return nil
    }
    
    /// The maximum distance between the entity and the target.
    ///
    var maxDistance: CGFloat?
    
    /// The source entity from which to compute the target.
    ///
    weak var source: Entity?
    
    /// The secondary source that should replace the `source` property when it becomes `nil`.
    ///
    weak var secondarySource: Entity?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - source: An optional source to start with.
    ///   - maxDistance: An optional maximum distance between the entity and the source.
    ///     The component will set the source to `nil` when `maximumDistance` is reached.
    ///
    init(source: Entity?, maxDistance: CGFloat?) {
        self.source = source
        self.maxDistance = maxDistance
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if source == nil && secondarySource != nil {
            source = secondarySource
            secondarySource = nil
        }
        
        guard let source = source else { return }
        
        guard source.component(ofType: HealthComponent.self)?.isDead != true else {
            if entity === Game.protagonist && source === Game.target { ControllableEntityState.clearSelection() }
            self.source = nil
            return
        }
        
        guard source.component(ofType: ConcealmentComponent.self)?.isConcealed != true else {
            if entity === Game.protagonist && source === Game.target { ControllableEntityState.clearSelection() }
            self.source = nil
            return
        }
        
        guard let maxDistance = maxDistance, let target = target else { return }
        
        let p = CGPoint(x: physicsComponent.position.x - target.x, y: physicsComponent.position.y - target.y)
        if (p.x * p.x + p.y * p.y).squareRoot() > maxDistance {
            if entity === Game.protagonist && source === Game.target { ControllableEntityState.clearSelection() }
            self.source = nil
        }
    }
}
