//
//  TextureAnimation.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Animation` type that animates a sequence of textures.
///
class TextureAnimation: Animation {
    
    let replaceable: Bool
    
    var duration: TimeInterval? {
        return animation.duration
    }
    
    /// A flag indicating whether or not the animation must be flipped vertically.
    ///
    /// - Note: The `TexturedAnimation` will not flip the animation by itself. Classes that use the
    ///   `TextureAnimation` should read this property and act accordingly.
    ///
    let flipped: Bool
    
    /// The animation to play.
    ///
    private let animation: SKAction
    
    /// Creates a new instance that animates a sequence of textures with optional waiting times between
    /// frames.
    ///
    /// - Parameters:
    ///   - images: An array with the names of the images to be used in the animation sequence.
    ///   - timePerFrame: The amount of time to wait before moving to the next frame of animation.
    ///   - replaceable: A flag stating whether or not the animation can be replaced.
    ///   - flipped: A flag indicating whether or not the animation is expected to be flipped.
    ///   - repeatForever: A flag indicating that the animation must restart every time it completes.
    ///   - waitings: An optional dictionary whose keys are frame indices and values are average waititing times.
    ///     Frames specified in the dictionary will be delayed by the given time interval. If the dictionary
    ///     contains `images.count` as a key, this delay is applied after all frames have been presented.
    ///     Any other indices out of bounds are ignored. The default value is `nil`.
    ///
    init(images: [String], timePerFrame: TimeInterval, replaceable: Bool, flipped: Bool, repeatForever: Bool,
         waitings: [Int: TimeInterval]? = nil) {
        
        self.replaceable = replaceable
        self.flipped = flipped
        
        if let waitings = waitings, !waitings.isEmpty {
            var textures = [SKTexture]()
            var actions = [SKAction]()
            
            for i in 0..<images.count {
                if let duration = waitings[i] {
                    if !textures.isEmpty {
                        // Create a single action for the current sequence of textures
                        actions.append(SKAction.animate(with: textures, timePerFrame: timePerFrame,
                                                        resize: true, restore: false))
                        // Reset the texture sequence
                        textures = []
                    }
                    actions.append(SKAction.wait(forDuration: duration, withRange: duration))
                }
                textures.append(TextureSource.createTexture(imageNamed: images[i]))
            }
            
            if !textures.isEmpty {
                // Create a single action for the remaining textures
                actions.append(SKAction.animate(with: textures, timePerFrame: timePerFrame,
                                                resize: true, restore: false))
            }
            
            if let duration = waitings[images.count] {
                // Apply final waiting time
                actions.append(SKAction.wait(forDuration: duration, withRange: duration))
            }
            
            let action = SKAction.sequence(actions)
            animation = repeatForever ? SKAction.repeatForever(action) : action
        } else {
            var textures = [SKTexture]()
            textures.reserveCapacity(images.count)
            
            for imageName in images {
                textures.append(TextureSource.createTexture(imageNamed: imageName))
            }
            
            let action = SKAction.animate(with: textures, timePerFrame: timePerFrame, resize: true, restore: false)
            animation = repeatForever ? SKAction.repeatForever(action) : action
        }
    }
    
    /// Creates a new instance that repeats the animation indefinitely, waiting for a given duration
    /// after each execution.
    ///
    /// - Parameters:
    ///   - images: An array with the names of the images to be used in the animation sequence.
    ///   - timePerFrame: The amount of time to wait before moving to the next frame of animation.
    ///   - replaceable: A flag stating whether or not the animation can be replaced.
    ///   - flipped: A flag indicating whether or not the animation is expected to be flipped.
    ///   - repeatDelay: The average time to wait before running the animation again.
    ///
    init(images: [String], timePerFrame: TimeInterval, replaceable: Bool, flipped: Bool, repeatDelay: TimeInterval) {
        
        self.replaceable = replaceable
        self.flipped = flipped
        
        var textures = [SKTexture]()
        textures.reserveCapacity(images.count)
        
        for imageName in images {
            textures.append(TextureSource.createTexture(imageNamed: imageName))
        }
        
        let animateAction = SKAction.animate(with: textures, timePerFrame: timePerFrame, resize: true, restore: false)
        let waitAction = SKAction.wait(forDuration: repeatDelay, withRange: repeatDelay)
        let action = SKAction.sequence([animateAction, waitAction])
        animation = SKAction.repeatForever(action)
    }
    
    /// Creates a new instance that presents a sequence of textures with fade in and fade out animations
    /// between each one.
    ///
    /// - Parameters:
    ///   - images: An array with the names of the images to be used in the animation sequence.
    ///   - replaceable: A flag stating whether or not the animation can be replaced.
    ///   - flipped: A flag indicating whether or not the animation is expected to be flipped.
    ///   - repeatForever: A flag indicating that the animation must restart every time it completes.
    ///   - fadeInDuration: The duration of the fade in animation.
    ///   - fadeOutDuration: The duration of the fade out animation.
    ///
    init(images: [String], replaceable: Bool, flipped: Bool, repeatForever: Bool,
         fadeInDuration: TimeInterval, fadeOutDuration: TimeInterval) {
        
        self.replaceable = replaceable
        self.flipped = flipped
        
        let fadeIn = SKAction.fadeIn(withDuration: fadeInDuration)
        let fadeOut = SKAction.fadeOut(withDuration: fadeOutDuration)
        var actions = [SKAction]()
        for image in images {
            actions.append(SKAction.setTexture(TextureSource.createTexture(imageNamed: image)))
            actions.append(fadeIn)
            actions.append(fadeOut)
        }
        
        let sequence = SKAction.sequence(actions)
        animation = repeatForever ? SKAction.repeatForever(sequence) : sequence
    }
    
    func play(node: SKNode) {
        replaceable ? node.run(animation, withKey: "Texture Animation") : node.run(animation)
    }
}
