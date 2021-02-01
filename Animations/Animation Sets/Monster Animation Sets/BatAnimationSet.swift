//
//  BatAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/14/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Bat` entity.
///
class BatAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Bat"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .attack, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Bat_Fly_Back_", 1, 5),
            ("Bat_Fly_Front_", 1, 5),
            ("Bat_Fly_Side_", 1, 5),
            
            ("Bat_Attack_Back_", 1, 5),
            ("Bat_Attack_Front_", 1, 5),
            ("Bat_Attack_Side_", 1, 5)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: BatAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addAttack()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Bat_Fly_Back_", first: 1, last: 5, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Bat_Fly_Front_", first: 1, last: 5, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Bat_Fly_Side_", first: 1, last: 5, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .idle, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Bat_Fly_Back_", first: 1, last: 5, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Bat_Fly_Front_", first: 1, last: 5, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Bat_Fly_Side_", first: 1, last: 5, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `attack` animations.
    ///
    private func addAttack() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Bat_Attack_Back_", first: 1, last: 5, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .attack, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Bat_Attack_Front_", first: 1, last: 5, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .attack, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Bat_Attack_Side_", first: 1, last: 5, reversing: true,
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
        
        images = ["Bat_Fly_Back_3"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Bat_Fly_Front_3"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Bat_Fly_Side_3"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
