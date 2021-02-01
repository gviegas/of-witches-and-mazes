//
//  ThrowingComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to throw.
///
class ThrowingComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a ThrowingComponent must also have a PhysicsComponent ")
        }
        return component
    }
    
    /// The current throwing.
    ///
    var throwing: Throwing?
    
    /// Computes the origin of a new throwing.
    ///
    /// - Parameters:
    ///   - length: The throwing's length.
    ///   - direction: The direction which the throwing will travel.
    /// - Returns: The throwing's origin point.
    ///
    private func computeThrowingOrigin(length: CGFloat, direction: CGVector) -> CGPoint {
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
    
    /// Tosses the current throwing.
    ///
    /// - Parameter location: The target point.
    /// - Returns: `true` if the throwing was successful, `false` otherwise.
    ///
    @discardableResult
    func toss(at location: CGPoint) -> Bool {
        guard let throwing = throwing, let level = (entity as? Entity)?.level else { return false }
        
        let pointA = physicsComponent.position
        let pointB = location
        let point = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
        let length = (point.x * point.x + point.y * point.y).squareRoot()
        let direction = CGVector(dx: point.x / length, dy: point.y / length)
        
        let origin = computeThrowingOrigin(length: throwing.size.width, direction: direction)
        let throwingNode = ThrowingNode(throwing: throwing, origin: origin,
                                        target: location, source: entity as? Entity)
        level.addNode(throwingNode)
        
        return true
    }
}
