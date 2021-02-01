//
//  NoxiousBarrelAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `NoxiousBarrel` entity.
///
class NoxiousBarrelAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Noxious Barrel"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.death]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let images = ImageArray.createFrom(baseName: "Noxious_Barrel_Break_", first: 1, last: 10)
        return Set<String>(images)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: NoxiousBarrelAnimationSet._identifier)
        let images = ImageArray.createFrom(baseName: "Noxious_Barrel_Break_", first: 1, last: 10)
        let deathAnimation = TextureAnimation(images: images, timePerFrame: 0.083, replaceable: false,
                                              flipped: false, repeatForever: false)
        addAnimationForAllDirections(deathAnimation, named: .death)
    }
}
