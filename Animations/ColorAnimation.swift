//
//  ColorAnimation.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/23/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Animation` type that applies color to sprites.
///
class ColorAnimation: Animation, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [hitKey, poisonedKey, cursedKey, concealedKey, revealedKey, heroizedKey, wardedKey, clearedKey]
    }
    
    private static let hitKey = "ColorAnimation.hit"
    private static let poisonedKey = "ColorAnimation.poisoned"
    private static let cursedKey = "ColorAnimation.cursed"
    private static let concealedKey = "ColorAnimation.concealed"
    private static let revealedKey = "ColorAnimation.revealed"
    private static let heroizedKey = "ColorAnimation.heroized"
    private static let wardedKey = "ColorAnimation.warded"
    private static let clearedKey = "ColorAnimation.cleared"
    
    let replaceable: Bool
    var duration: TimeInterval? { return animation.duration }
    
    /// The flag stating whether the animation has an action that undoes its effects. If `false`,
    /// it is expected that applications of this animation will be balanced with the same number
    /// of `ColorAnimation.cleared` applications.
    ///
    let animationUndoesItself: Bool
    
    /// The animation to play.
    ///
    private let animation: SKAction
    
    /// A `ColorAnimation` representing an injure. It paints the sprite red. Lasts 0.5 seconds.
    ///
    static var hit: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.hitKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .red, blendFactor: 0.75, duration: 0.5, replaceable: true)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.hitKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` representing a poison affliction. It paints the sprite green. Lasts 0.5 seconds.
    ///
    static var poisoned: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.poisonedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .green, blendFactor: 0.75, duration: 0.5, replaceable: true)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.poisonedKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` representing a curse affliction. It paints the sprite purple. Lasts 0.5 seconds.
    ///
    static var cursed: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.cursedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .purple, blendFactor: 0.75, duration: 0.5,
                                            replaceable: true)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.cursedKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` representing concealment. It makes the sprite semitransparent.
    ///
    /// - Note: This color animation will last indefinitely. Applying the `revealed` color animation
    ///   will undo the changes.
    ///
    static var concealed: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.concealedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .clear, blendFactor: 0.75, replaceable: false)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.concealedKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` that clears any colors applied to the sprite, to be used when undoing
    /// the `concealed` color animation.
    ///
    static var revealed: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.revealedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .clear, blendFactor: 0, replaceable: false)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.revealedKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` representing the `HeroismCondition`'s effect. It paints the sprite yellow.
    ///
    /// - Note: This color animation will last indefinitely. Applying the `cleared` color animation
    ///   will undo the changes.
    ///
    static var heroized: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.heroizedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .yellow, blendFactor: 0.75, replaceable: false)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.heroizedKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` representing the `ImmunityCondition`'s effect. It paints the sprite blue.
    ///
    /// - Note: This color animation will last indefinitely. Applying the `cleared` color animation
    ///   will undo the changes.
    ///
    static var warded: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.wardedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .blue, blendFactor: 0.75, replaceable: false)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.wardedKey)
        return colorAnimation
    }
    
    /// A `ColorAnimation` that clears any colors applied to the sprite, to be used when undoing
    /// color animations other than `concealed`.
    ///
    static var cleared: ColorAnimation {
        if let storedAnimation = AnimationSource.getAnimation(forKey: ColorAnimation.clearedKey) {
            return storedAnimation as! ColorAnimation
        }
        let colorAnimation = ColorAnimation(color: .clear, blendFactor: 0, replaceable: false)
        AnimationSource.storeAnimation(colorAnimation, forKey: ColorAnimation.clearedKey)
        return colorAnimation
    }
    
    /// Creates a new instance that colorizes a sprite for a given duration.
    ///
    /// - Parameters:
    ///   - color: The color to use.
    ///   - blendFactor: The color blend factor.
    ///   - duration: The duration of the animation.
    ///   - replaceable: A flag stating whether or not the animation can be replaced.
    ///
    private init(color: NSColor, blendFactor: CGFloat, duration: TimeInterval, replaceable: Bool) {
        let colorize = SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: 0)
        let wait = SKAction.wait(forDuration: duration)
        let undo = SKAction.colorize(with: color, colorBlendFactor: 0, duration: 0)
        animation = SKAction.sequence([colorize, wait, undo])
        self.replaceable = replaceable
        animationUndoesItself = true
    }
    
    /// Creates a new instance that colorizes a sprite.
    ///
    /// - Parameters:
    ///   - color: The color to use.
    ///   - blendFactor: The color blend factor.
    ///   - replaceable: A flag stating whether or not the animation can be replaced.
    ///
    private init(color: NSColor, blendFactor: CGFloat, replaceable: Bool) {
        animation = SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: 0)
        self.replaceable = replaceable
        animationUndoesItself = false
    }
    
    func play(node: SKNode) {
        replaceable ? node.run(animation, withKey: "Color Animation") : node.run(animation)
    }
}
