//
//  GelatinousCubeAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `GelatinousCube` entity.
///
class GelatinousCubeAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Gelatinous Cube"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let pulse = ImageArray.createFrom(baseName: "Gelatinous_Cube_Pulse_", first: 1, last: 10)
        return Set<String>(pulse)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: GelatinousCubeAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        let images = ImageArray.createFrom(baseName: "Gelatinous_Cube_Pulse_", first: 1, last: 10, reversing: true)
        let idle = TextureAnimation(images: images, timePerFrame: 0.1, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimationForAllDirections(idle, named: .idle)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        let images = ImageArray.createFrom(baseName: "Gelatinous_Cube_Pulse_", first: 1, last: 10, reversing: true)
        let move = TextureAnimation(images: images, timePerFrame: 0.1, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimationForAllDirections(move, named: .walk)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        let images = ["Gelatinous_Cube_Pulse_9"]
        let quell = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimationForAllDirections(quell, named: .quell)
    }
}
