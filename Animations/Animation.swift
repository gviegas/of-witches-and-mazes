//
//  Animation.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/11/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol defining an animation.
///
/// The main purpose of an `Animation` type is to run actions on an entity's node, usually to
/// animate through a sequence of textures. Animations should be stored in the `AnimationSource`,
/// so instances of animations can be shared among different entities.
///
protocol Animation {
    
    /// The flag stating whether or not the animation can be replaced by another one.
    /// If set to `false`, the animation must complete before another one starts playing.
    ///
    var replaceable: Bool { get }
    
    /// The optional duration of the animation.
    ///
    var duration: TimeInterval? { get }
    
    /// Plays the animation for the given node.
    ///
    /// - Parameter node: The node to be animated.
    ///
    func play(node: SKNode)
}
