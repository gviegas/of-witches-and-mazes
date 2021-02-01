//
//  DirectionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/31/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that represents the four basic compass directions.
///
enum Direction: String {
    case north, south, east, west
    
    /// Computes the absolute direction from a given angle.
    ///
    /// - Parameter radians: The angle in radians.
    /// - Returns: The `Direction` that better approximates the given angle.
    ///
    static func fromAngle(_ radians: CGFloat) -> Direction {
        let pi = CGFloat.pi
        let offset = pi / 4.0
        let angle = radians < 0 ? pi * 2.0 + radians : radians
        
        switch angle {
        case (pi / 2.0 - offset)...(pi / 2.0 + offset):
            return .north
        case (pi - offset)...(pi + offset):
            return .west
        case (pi * 1.5 - offset)...(pi * 1.5 + offset):
            return .south
        default:
            return .east
        }
    }
    
    /// Computes a direction vector.
    ///
    /// - Returns: A vector that represents the direction.
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
        }
        return vector
    }
}

/// A component that provides an entity with absolute facing directions.
///
class DirectionComponent: Component {
    
    /// The current direction that the entity is facing.
    ///
    var direction: Direction {
        didSet { broadcast() }
    }
    
    /// Creates a new instance facing the given direction.
    ///
    /// - Parameter direction: The facing direction.
    ///
    init(direction: Direction) {
        self.direction = direction
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
