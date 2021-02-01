//
//  Influence.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/14/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the influence effect, used by the `InfluenceComponent`.
///
protocol Influence: AnyObject, Identifiable {
    
    /// The interaction defining the influenciable targets.
    ///
    var interaction: Interaction { get }
    
    /// The radius of influence.
    ///
    var radius: CGFloat { get }
    
    /// The maximum range limiting where the influence originates.
    ///
    var range: CGFloat { get }
    
    /// The time it takes for the influence to start.
    ///
    var delay: TimeInterval { get }
    
    /// The duration of the influence, not considering the delay nor the conclusion.
    ///
    var duration: TimeInterval { get }
    
    /// The time it takes for the influence to conclude.
    ///
    var conclusion: TimeInterval { get }
    
    /// The optional `Animation` for the influence.
    ///
    var animation: Animation? { get }
    
    /// The optional `SoundFX` to play when executing the influence.
    ///
    var sfx: SoundFX? { get }
    
    /// Informs that a target was affected by the influence.
    ///
    /// - Parameters
    ///   - node: The influenced node.
    ///   - source: An optional entity to be identified as the source of the influence.
    ///
    func didInfluence(node: SKNode, source: Entity?)
}

extension Influence {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
}
