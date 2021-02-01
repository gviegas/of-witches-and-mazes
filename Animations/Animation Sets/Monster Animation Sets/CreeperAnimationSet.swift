//
//  CreeperAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Creeper` entity.
///
class CreeperAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Creeper"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .causeBlast, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let creep = ImageArray.createFrom(baseName: "Creeper_Creep_", first: 1, last: 6)
        return Set<String>(creep + ["Creeper"])
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: CreeperAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addCauseBlast()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        let images = ["Creeper"]
        let animation = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                         repeatForever: false)
        addAnimationForAllDirections(animation, named: .idle)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        let images = ImageArray.createFrom(baseName: "Creeper_Creep_", first: 1, last: 6)
        let move = TextureAnimation(images: images, timePerFrame: 0.05,
                                    replaceable: true, flipped: false, repeatForever: true)
        addAnimationForAllDirections(move, named: .walk)
    }
    
    /// Adds `causeBlast` animations.
    ///
    private func addCauseBlast() {
        let images = ["Creeper"]
        let causeBlast = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                          repeatForever: false)
        addAnimationForAllDirections(causeBlast, named: .causeBlast)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        let images = ["Creeper"]
        let quell = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimationForAllDirections(quell, named: .quell)
    }
}
