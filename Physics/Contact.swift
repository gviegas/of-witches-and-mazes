//
//  Contact.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/28/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines a contact between physics bodies.
///
class Contact {
    
    /// The physics body of the source node (the node whose name was registered on
    /// `ContactNotifier` to receive notifications).
    ///
    let body: SKPhysicsBody
    
    /// The physics body of the target node.
    ///
    let otherBody: SKPhysicsBody
    
    /// The contact point between the bodies.
    ///
    let contactPoint: CGPoint
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - body: The physics body of the source.
    ///   - otherBody: The physics body of the target.
    ///   - contactPoint: The contact point of the interaction.
    ///
    init(body: SKPhysicsBody, otherBody: SKPhysicsBody, contactPoint: CGPoint) {
        self.body = body
        self.otherBody = otherBody
        self.contactPoint = contactPoint
    }
}
