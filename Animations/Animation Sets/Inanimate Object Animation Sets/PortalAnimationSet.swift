//
//  PortalAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Portal` entity.
///
class PortalAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Portal"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let images = ImageArray.createFrom(baseName: "Portal_", first: 1, last: 20)
        return Set<String>(images)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: PortalAnimationSet._identifier)
        let images = ImageArray.createFrom(baseName: "Portal_", first: 1, last: 20, reversing: true,
                                           dropFirst: true, dropLast: true)
        let idleAnimation = TextureAnimation(images: images, timePerFrame: 0.133, replaceable: false,
                                             flipped: false, repeatForever: true)
        addAnimationForAllDirections(idleAnimation, named: .idle)
    }
}
