//
//  MissileComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/19/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to fire missiles.
///
class MissileComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a MissileComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    /// The interaction for the missiles.
    ///
    private var interaction: Interaction
    
    /// The missile to propel.
    ///
    var missile: Missile?
    
    /// Create a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: The `Interaction` instance that defines which targets should be hit.
    ///   - missile: An optional `Missile` instance to set on creation. The default value is `nil`.
    ///
    init(interaction: Interaction, missile: Missile? = nil) {
        self.interaction = interaction
        self.missile = missile
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Computes the origin of a new missile to be propelled.
    ///
    /// - Parameters:
    ///   - length: The missile's length.
    ///   - direction: The direction which the missile will be propelled.
    /// - Returns: The missile's origin point.
    ///
    private func computeMissileOrigin(length: CGFloat, direction: CGVector) -> CGPoint {
        let x, y: CGFloat
        let referenceShape = physicsComponent.physicsShape
        
        switch referenceShape {
        case .circle(let radius, _):
            if radius * 2.0 >= length {
                x = length / 2.0 * direction.dx
                y = length / 2.0 * direction.dy
            } else {
                x = ((length - radius * 2.0) / 2.0 + radius) * direction.dx
                y = ((length - radius * 2.0) / 2.0 + radius) * direction.dy
            }
            
        case .rectangle(let size, _):
            if size.width >= length {
                x = size.width / 2.0 * direction.dx
            } else {
                x = ((length - size.width) / 2.0 + size.width / 2.0) * direction.dx
            }
            if size.height >= length {
                y = size.height / 2.0 * direction.dy
            } else {
                y = ((length - size.height) / 2.0 + size.height / 2.0) * direction.dy
            }
        }
        
        let referencePosition = physicsComponent.position
        return CGPoint(x: referencePosition.x + x, y: referencePosition.y + y)
    }
    
    /// Propels a missile.
    ///
    /// - Parameter location: The point to propel towards.
    /// - Returns: `true` if the missile could be propelled, `false` otherwise.
    ///
    @discardableResult
    func propelMissile(towards location: CGPoint) -> Bool {
        guard let missile = missile, let level = (entity as? Entity)?.level else { return false }

        let pointA = physicsComponent.position
        let pointB = location
        let point = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
        let length = (point.x * point.x + point.y * point.y).squareRoot()
        let direction = CGVector(dx: point.x / length, dy: point.y / length)
        let zRotation = atan2(point.y, point.x)
        
        let position = computeMissileOrigin(length: missile.size.width, direction: direction)
        let missileNode = MissileNode(missile: missile, position: position, direction: direction,
                                      zRotation: zRotation, interaction: interaction, source: entity as? Entity)
        
        level.addNode(missileNode)
        
        return true
    }
}
