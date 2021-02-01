//
//  SpikeTrapAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `SpikeTrap` entity.
///
class SpikeTrapAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Spike Trap"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.trigger, .triggerEnd]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let images = ImageArray.createFrom(baseName: "Spike_Trap_", first: 1, last: 4)
        return Set<String>(images)
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: SpikeTrapAnimationSet._identifier)
        let images = ImageArray.createFrom(baseName: "Spike_Trap_", first: 1, last: 4)
        
        let triggerAnimation = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true,
                                                flipped: false, repeatForever: false)
        addAnimationForAllDirections(triggerAnimation, named: .trigger)
        
        let triggerEndAnimation = TextureAnimation(images: images.reversed(), timePerFrame: 0.033,
                                                   replaceable: true, flipped: false, repeatForever: false)
        addAnimationForAllDirections(triggerEndAnimation, named: .triggerEnd)
    }
}
