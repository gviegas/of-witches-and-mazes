//
//  WillOTheWispAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `WillOTheWisp` entity.
///
class WillOTheWispAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Will-o'-the-wisp"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .causeBlast, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let drift = ImageArray.createFrom(baseName: "Will-o'-the-wisp_Drift_", first: 1, last: 20)
        let attack = ImageArray.createFrom(baseName: "Will-o'-the-wisp_Attack_", first: 1, last: 20)
        return Set<String>(drift + attack)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: WillOTheWispAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addCauseBlast()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        let images = ImageArray.createFrom(baseName: "Will-o'-the-wisp_Drift_", first: 1, last: 20, reversing: true)
        let idle = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimationForAllDirections(idle, named: .idle)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        let images = ImageArray.createFrom(baseName: "Will-o'-the-wisp_Drift_", first: 1, last: 20, reversing: true)
        let move = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimationForAllDirections(move, named: .walk)
    }
    
    /// Adds `causeBlast` animations.
    ///
    private func addCauseBlast() {
        let images = ImageArray.createFrom(baseName: "Will-o'-the-wisp_Attack_", first: 1, last: 20)
        let causeBlast = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                          repeatForever: false)
        addAnimationForAllDirections(causeBlast, named: .causeBlast)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        let images = ["Will-o'-the-wisp_Drift_1"]
        let quell = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimationForAllDirections(quell, named: .quell)
    }
}
