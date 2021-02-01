//
//  DirectionalAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/11/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents a set of related `Animation` instances, intended to be used by entities
/// that have a `DirectionComponent`.
///
class DirectionalAnimationSet {
    
    /// The animation set identifier.
    ///
    let identifier: String
    
    /// The animation set, with directions as subkeys.
    ///
    private var animationSet: [AnimationName: [Direction: Animation]] = [:]
    
    /// Creates a new instance using the given identifier.
    ///
    /// - Parameter identifier: The identifier to use.
    ///
    init(identifier: String) {
        self.identifier = identifier
    }
    
    /// Makes a string to be used as `AnimationSource` key when storing an animation for the
    /// given parameters.
    ///
    /// This method can be used by `AnimationUser` types that need to know, ahead of time,
    /// which key their animations would use when created by a `DirectionalAnimationSet`.
    ///
    /// - Parameters:
    ///   - identifier: The identifier used by the `DirectionalAnimationSet` instance.
    ///   - name: The `AnimationName` under which the animation would be stored.
    ///   - direction: The `Direction` under which the animation would be stored.
    /// - Returns: A string to be used as key in the `AnimationSource`.
    ///
    class func makeKey(identifier: String, name: AnimationName, direction: Direction) -> String {
        return "\(identifier).\(name.rawValue).\(direction.rawValue)"
    }
    
    /// Makes a string set to be used as `AnimationSource` keys when storing animations for the
    /// given parameters.
    ///
    /// This method can be used by `AnimationUser` types that need to know, ahead of time,
    /// which key their animations would use when created by a `DirectionalAnimationSet`.
    ///
    /// - Parameters:
    ///   - identifier: The identifier used by the `DirectionalAnimationSet` instance.
    ///   - names: The set of `AnimationName`s under which the animations would be stored.
    /// - Returns: A string set, containing keys for every direction of each name, to be
    ///   used in the `AnimationSource`.
    ///
    class func makeKeysForAllDirections(identifier: String, names: Set<AnimationName>) -> Set<String> {
        let keysForAllDirections: (AnimationName) -> Set<String> = { name in
            var keys = Set<String>()
            for direction in [Direction.north, Direction.south, Direction.east , Direction.west] {
                let key = DirectionalAnimationSet.makeKey(identifier: identifier, name: name, direction: direction)
                keys.insert(key)
            }
            return keys
        }
        
        return names.reduce(Set<String>()) { (result, name) in
            return result.union(keysForAllDirections(name))
        }
    }
    
    /// Adds a new animation to the set.
    ///
    /// - Parameters:
    ///   - animation: The `Animation` instance to add.
    ///   - name: The `AnimationName` under which the animation should be stored.
    ///   - direction: The `Direction` under which the animation should be stored.
    /// - Returns: `true` if the addition was successful, `false` if the set already contains the animation.
    ///
    @discardableResult
    func addAnimation(_ animation: Animation, named name: AnimationName, forDirection direction: Direction) -> Bool {
        if let _ = animationSet[name]?[direction] { return false }
        
        let key = DirectionalAnimationSet.makeKey(identifier: identifier, name: name, direction: direction)
        AnimationSource.storeAnimation(animation, forKey: key)
        
        // The AnimationSource instance only stores new animations, retrieve it from the source to guarantee
        // that the right one is being added
        let animationFromSource = AnimationSource.getAnimation(forKey: key)!
        
        if let _ = animationSet[name] {
            animationSet[name]![direction] = animationFromSource
        } else {
            animationSet[name] = [direction: animationFromSource]
        }
        
        return true
    }
    
    /// Adds the same animation for all directions.
    ///
    /// This method is useful for objects that have a single animation for all directions. Thus,
    /// instead of calling `addAnimation(_:named:forDirection:)` for each directions, one call of
    /// this method will suffice.
    ///
    /// - Parameters:
    ///   - animation: The `Animation` instance to add.
    ///   - name: The `AnimationName` under which the animation should be stored.
    /// - Returns: If all the additions were successful, then `true` is returned. If the set
    ///   already contains the animation for any of the possible directions, `false` is returned
    ///   and nothing is added to the set.
    ///
    @discardableResult
    func addAnimationForAllDirections(_ animation: Animation, named name: AnimationName) -> Bool {
        let directions: Set<Direction> = [.north, .south, .east, .west]
        if let animations = animationSet[name], animations.count == directions.count { return false }
        for direction in directions { addAnimation(animation, named: name, forDirection: direction) }
        return true
    }
    
    /// Retrieves the animation for the given name and direction.
    ///
    /// - Parameters:
    ///   - name: The name of the animation to retrieve.
    ///   - direction: The `Direction` of the animation.
    /// - Returns: The animation for the given name and direction, or nil if not found.
    ///
    func getAnimation(named name: AnimationName, forDirection direction: Direction) -> Animation? {
        return animationSet[name]?[direction]
    }
    
    /// Removes an animation from the set.
    ///
    /// - Parameters:
    ///   - name: The name of the animation to retrieve.
    ///   - direction: The `Direction` of the animation.
    ///
    func removeAnimation(named name: AnimationName, forDirection direction: Direction) {
        animationSet[name]?.removeValue(forKey: direction)
    }
}
