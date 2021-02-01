//
//  MovementComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/31/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that defines movement directions, from which a direction vector can be computed.
///
enum MovementDirection {
    case north, south, east, west, northeast, northwest, southeast, southwest
    
    /// Computes a direction vector for the `MovementDirection`.
    ///
    /// - Returns: The movement vector.
    ///
    func asVector() -> CGVector {
        let vector: CGVector
        switch self {
        case .north:
            vector = CGVector(dx: 0, dy: 1.0)
        case .south:
            vector = CGVector(dx: 0, dy: -1.0)
        case .east:
            vector = CGVector(dx: 1.0, dy: 0)
        case .west:
            vector = CGVector(dx: -1.0, dy: 0)
        case .northeast:
            vector = CGVector(dx: 0.7071, dy: 0.7071)
        case .northwest:
            vector = CGVector(dx: -0.7071, dy: 0.7071)
        case .southeast:
            vector = CGVector(dx: 0.7071, dy: -0.7071)
        case .southwest:
            vector = CGVector(dx: -0.7071, dy: -0.7071)
        }
        return vector
    }
}

/// An enum that defines movement speed values.
///
enum MovementSpeed {
    case stopped, verySlow, slow, normal, fast, veryFast, controllable
    
    /// The numeric value for the speed value.
    ///
    /// - Note: For most cases, this getter will compute a random value within a predefined range.
    ///   Thus, subsequent retrievals are likely to generate different values.
    ///
    var numericValue: CGFloat {
        let range: ClosedRange<CGFloat>
        switch self {
        case .stopped:
            range = 0...0
        case .verySlow:
            range = 40.0...45.0
        case .slow:
            range = 80.0...90.0
        case .normal:
            range = 185.0...200.0
        case .fast:
            range = 320.0...340.0
        case .veryFast:
            range = 375.0...400.0
        case .controllable:
            range = 300.0...300.0
        }
        return CGFloat.random(in: range)
    }
}

/// A component that enables an entity to move.
///
class MovementComponent: Component {

    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a MovementComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a MovementComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    /// The base speed.
    ///
    private let baseSpeed: CGFloat
    
    /// The private backing for the multiplier property.
    ///
    private var _multiplier: CGFloat = 1.0
    
    /// The multiplier bounds.
    ///
    let bounds: ClosedRange<CGFloat> = 0.05...2.0
    
    /// The vector that represents the direction to move.
    ///
    var movement = CGVector.zero {
        didSet {
            guard movement != oldValue else { return }
            movement == .zero ? physicsComponent.pin() : physicsComponent.unpin()
        }
    }
    
    /// The multiplier applied when computing the current speed.
    ///
    var multiplier: CGFloat {
        return max(bounds.lowerBound, min(bounds.upperBound, _multiplier))
    }
    
    /// The scalar to be multiplied by the movement vector to obtain the final translation.
    ///
    var currentSpeed: CGFloat {
        return baseSpeed * multiplier
    }
    
    /// Creates a new instance with the given speed.
    ///
    /// - Parameter baseSpeed: The base movement speed for the entity.
    ///
    init(baseSpeed: CGFloat) {
        self.baseSpeed = baseSpeed
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Computes the new position for the entity, taking into consideration the elapsed time
    /// since the last update.
    ///
    /// - Parameter seconds: The elapsed time since the last update.
    ///
    private func move(deltaTime seconds: CGFloat) {
        guard movement != CGVector.zero else { return }
        
        nodeComponent.node.position.x += movement.dx * currentSpeed * seconds
        nodeComponent.node.position.y += movement.dy * currentSpeed * seconds
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        move(deltaTime: CGFloat(seconds))
    }
    
    /// Modifies the speed multiplier by the given amount.
    ///
    /// - Parameter amount: The amount to be summed with the current value.
    ///
    func modifyMultiplier(by amount: CGFloat) {
        _multiplier += amount
    }
    
    /// Checks if the speed multiplier is capped towards its lower bound (i.e., it cannot be
    /// decreased any further).
    ///
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isMultiplierLowerCapped() -> Bool {
        return _multiplier <= bounds.lowerBound
    }
    
    /// Checks if the speed multiplier is capped towards its upper bound (i.e., it cannot be
    /// increased any further).
    ///
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isMultiplierUpperCapped() -> Bool {
        return _multiplier >= bounds.upperBound
    }
}
