//
//  AnimationReleaser.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that manages the discarding of animations stored in the `AnimationSource`.
///
class AnimationRelease {
    
    /// The set of keys managed.
    ///
    let animationKeys: Set<String>
    
    init(animationKeys: Set<String>) {
        self.animationKeys = animationKeys
    }
    
    /// Releases the animations.
    ///
    /// - Parameter keysToIgnore: A set containing keys of animations that must not be released.
    ///   The default value is an empty set, meaning that every animation whose key is found in the
    ///   instance's `animationKeys` property will be released.
    ///
    func releaseAnimations(ignoringKeys keysToIgnore: Set<String> = []) {
        let animationKeys = [String](self.animationKeys.subtracting(keysToIgnore))
        AnimationSource.discardAnimations(forKeys: animationKeys)
    }
}
