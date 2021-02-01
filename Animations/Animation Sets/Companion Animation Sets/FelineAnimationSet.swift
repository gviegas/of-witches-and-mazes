//
//  FelineAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Feline` entity.
///
class FelineAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Feline"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .attack, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Feline_Idle_Back_", 1, 6),
            ("Feline_Idle_Front_", 1, 6),
            ("Feline_Idle_Side_", 1, 6),
            
            ("Feline_Walk_Back_", 1, 11),
            ("Feline_Walk_Front_", 1, 11),
            ("Feline_Walk_Side_", 1, 11),
            
            ("Feline_Attack_Back_", 1, 9),
            ("Feline_Attack_Front_", 1, 9),
            ("Feline_Attack_Side_", 1, 9)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: FelineAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addAttack()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Feline_Idle_Back_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 3.5, images.count / 2 + 1: 3.0])
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Feline_Idle_Front_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 3.5, images.count / 2 + 1: 3.0])
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Feline_Idle_Side_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true, waitings: [1: 3.5, images.count / 2 + 1: 3.0])
        addAnimation(east, named: .idle, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true, waitings: [1: 3.5, images.count / 2 + 1: 3.0])
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Feline_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Feline_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Feline_Walk_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `attack` animations.
    ///
    private func addAttack() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Feline_Attack_Back_", first: 1, last: 9, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .attack, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Feline_Attack_Front_", first: 1, last: 9, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .attack, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Feline_Attack_Side_", first: 1, last: 9, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .attack, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .attack, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Feline_Idle_Back_6"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Feline_Idle_Front_6"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Feline_Idle_Side_6"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
