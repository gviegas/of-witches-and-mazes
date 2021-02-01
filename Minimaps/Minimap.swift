//
//  Minimap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the requirements for a minimap type.
///
protocol Minimap: AnyObject {
    
    /// The node where all the minimap contents must be appended.
    ///
    var node: SKNode { get }
    
    /// The size of the minimap frame.
    ///
    var size: CGSize { get }
    
    /// The entity whose position should be used as a reference point
    /// when drawing the minimap.
    ///
    var referenceEntity: Entity? { get set }
    
    /// Updates the minimap.
    ///
    /// - Parameter seconds: The elapsed time since the last update.
    ///
    func update(deltaTime seconds: TimeInterval)
}
