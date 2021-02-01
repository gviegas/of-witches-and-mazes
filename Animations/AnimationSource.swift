//
//  AnimationSource.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/11/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents the source of animations for a game.
///
/// The purpose of this class is to allow the sharing and reuse of animations. An `Animation` type
/// should be created only once and then stored in the `AnimationSource`. Doing so allow animation
/// instances to be shared with calls to `getAnimation(forKey:)`.
///
class AnimationSource {
    
    /// The stored animations.
    ///
    private static var animations: [String: Animation] = [:]
    
    private init() {}
    
    /// Stores a new animation for the given key.
    ///
    /// - Note: This method does not replace animations. If a stored key must be used to identify a
    ///   different animation, it must first be removed with a call to `discardAnimation(forKey:)`.
    ///
    /// - Parameters:
    ///   - animation: The animation to store.
    ///   - key: The key that identifies the animation.
    ///
    class func storeAnimation(_ animation: Animation, forKey key: String) {
        if let _ = animations[key] { return }
        animations[key] = animation
    }
    
    /// Retrieves the animation stored under the given key.
    ///
    /// - Parameter key: The key that identifies the animation.
    /// - Returns: The `Animation` identified by the given key, or `nil` if not found.
    ///
    class func getAnimation(forKey key: String) -> Animation? {
        return animations[key]
    }
    
    /// Discards a stored animation identified by the given key.
    ///
    /// - Parameter key: The key that identifies the animation.
    ///
    class func discardAnimation(forKey key: String) {
        animations.removeValue(forKey: key)
    }
    
    /// Discards stored animations identified by the given keys.
    ///
    /// - Parameter keys: The list of keys that identifies the animations.
    ///
    class func discardAnimations(forKeys keys: [String]) {
        keys.forEach { animations.removeValue(forKey: $0) }
    }
    
    #if DEBUG
    class func DEBUGDescription() {
        print("---------------------------------------------------------------")
        print("--AnimationSource #\(animations.count)--")
        animations.forEach { print($0.key) }
        print("---------------------------------------------------------------", terminator: "\n\n")
    }
    #endif
}
