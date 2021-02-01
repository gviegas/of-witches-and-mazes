//
//  BarrelAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Barrel` entity.
///
class BarrelAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Barrel"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.death]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let images = ImageArray.createFrom(baseName: "Barrel_Break_", first: 1, last: 6)
        return Set<String>(images)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: BarrelAnimationSet._identifier)
        let images = ImageArray.createFrom(baseName: "Barrel_Break_", first: 1, last: 6)
        let deathAnimation = TextureAnimation(images: images, timePerFrame: 0.083, replaceable: false,
                                              flipped: false, repeatForever: false)
        addAnimationForAllDirections(deathAnimation, named: .death)
    }
}
