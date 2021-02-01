//
//  AcidPoolAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `AcidPool` entity.
///
class AcidPoolAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Acid Pool"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.trigger]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let images = ImageArray.createFrom(baseName: "Acid_Pool_", first: 1, last: 4)
        return Set<String>(images)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: AcidPoolAnimationSet._identifier)
        let images = ImageArray.createFrom(baseName: "Acid_Pool_", first: 1, last: 4, reversing: true)
        let triggerAnimation = TextureAnimation(images: images, timePerFrame: 0.133, replaceable: false,
                                                flipped: false, repeatForever: true)
        addAnimationForAllDirections(triggerAnimation, named: .trigger)
    }
}
