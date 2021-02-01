//
//  RayComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A component that enables an entity to cause rays.
///
class RayComponent: Component {
    
    private var directionComponent: DirectionComponent {
        guard let component = entity?.component(ofType: DirectionComponent.self) else {
            fatalError("An entity with a RayComponent must also have a DirectionComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a RayComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity?.component(ofType: TargetComponent.self) else {
            fatalError("An entity with a RayComponent must also have a TargetComponent")
        }
        return component
    }
    
    /// The interaction for the missiles.
    ///
    private var interaction: Interaction
    
    /// The ray to cause.
    ///
    var ray: Ray?
    
    /// Create a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: The `Interaction` instance that defines which targets should be hit.
    ///   - ray: An optional `Ray` instance to set on creation. The default value is `nil`.
    ///
    init(interaction: Interaction, ray: Ray? = nil) {
        self.interaction = interaction
        self.ray = ray
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Causes a ray.
    ///
    /// - Parameter location: The point toward which the ray must be caused.
    /// - Returns: `true` if the ray could be caused, `false` otherwise.
    ///
    @discardableResult
    func causeRay(towards location: CGPoint) -> Bool {
        guard let ray = ray, let level = (entity as? Entity)?.level else { return false }
        
        let pointA = physicsComponent.position
        let pointB = location
        let point = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
        let length = (point.x * point.x + point.y * point.y).squareRoot()
        let direction = CGVector(dx: point.x / length, dy: point.y / length)
        let zRotation = atan2(point.y, point.x)
        
        let position = physicsComponent.position
        let rayNode = RayNode(ray: ray, position: position, direction: direction, zRotation: zRotation,
                              interaction: interaction, source: entity as? Entity)
        
        level.addNode(rayNode)
        
        return true
    }
}
