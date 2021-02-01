//
//  Throwing.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the throwing effect, used by the `ThrowingComponent`.
///
protocol Throwing: AnyObject, Identifiable {
    
    /// The interaction defining the contactable targets.
    ///
    var interaction: Interaction { get }
    
    /// The size of the throwing.
    ///
    var size: CGSize { get }
    
    /// The speed of the throwing.
    ///
    var speed: CGFloat { get }
    
    /// The maximum range limiting the throwing's reach.
    ///
    var range: CGFloat { get }
    
    /// The time it takes for the throwing to start.
    ///
    var delay: TimeInterval { get }
    
    /// The duration of the throwing, not considering the delay nor the conclusion.
    ///
    var duration: TimeInterval { get }
    
    /// The time it takes for the throwing to end.
    ///
    var conclusion: TimeInterval { get }
    
    /// The flag stating whether the throwing must complete execution after the first contact.
    ///
    var completeOnContact: Bool { get }
    
    /// The flag stating whether the throwing node must be z-rotated based on the direction of the throw.
    ///
    var isRotational: Bool { get }
    
    /// The optional `Animation` instances for the throwing.
    ///
    var animation: (initial: Animation?, main: Animation?, final: Animation?)? { get }
    
    /// The optional `SoundFX` to play when executing the throwing.
    ///
    var sfx: SoundFX? { get }
    
    /// Informs that the throwing has contacted a target.
    ///
    /// - Parameters:
    ///   - node: The contacted node.
    ///   - location: The location where the contact took place.
    ///   - source: An optional entity to be identified as the source of the throwing.
    ///
    func didContact(node: SKNode, location: CGPoint, source: Entity?)
    
    /// Informs that the throwing has reached its destination or exceeded its maximum range.
    ///
    /// - Parameters:
    ///   - destination: The point where the throwing completed its execution.
    ///   - totalContacts: The total number of contacted nodes since the throwing started.
    ///   - source: An optional entity to be identified as the source of the throwing.
    ///
    func didReachDestination(_ destination: CGPoint, totalContacts: Int, source: Entity?)
}

extension Throwing {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
}
