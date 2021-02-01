//
//  Touch.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the touch effect, used by the `TouchComponent`.
///
protocol Touch: AnyObject, Identifiable {
    
    /// The flag indicating whether the touch effect is hostile or friendly.
    ///
    var isHostile: Bool { get }
    
    /// The maximum range limiting where the touch effect originates.
    ///
    var range: CGFloat { get }
    
    /// The time it takes for the touch effect to start.
    ///
    var delay: TimeInterval { get }
    
    /// The duration of the touch effect, not considering the delay nor the conclusion.
    ///
    var duration: TimeInterval { get }
    
    /// The time it takes for the rouch effect to conclude.
    ///
    var conclusion: TimeInterval { get }
    
    /// The optional `Animation` for the touch effect.
    ///
    var animation: Animation? { get }
    
    /// The optional `SoundFX` to play when executing the touch effect.
    ///
    var sfx: SoundFX? { get }
    
    /// Informs that a target was affected by the influence.
    ///
    /// - Parameters
    ///   - node: The entity affected by the touch effect.
    ///   - source: An optional entity to be identified as the source of the touch effect.
    ///
    func didTouch(target: Entity, source: Entity?)
}

extension Touch {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
}
