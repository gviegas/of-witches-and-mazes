//
//  GigasAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Gigas` entity.
///
class GigasAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Gigas"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .attack, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Gigas_Idle_Back_", 1, 7),
            ("Gigas_Idle_Front_", 1, 7),
            ("Gigas_Idle_Side_", 1, 7),
            
            ("Gigas_Walk_Back_", 1, 11),
            ("Gigas_Walk_Front_", 1, 11),
            ("Gigas_Walk_Side_", 1, 11),
            
            ("Gigas_Attack_Back_", 1, 10),
            ("Gigas_Attack_Front_", 1, 10),
            ("Gigas_Attack_Side_", 1, 10)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: GigasAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addAttack()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Gigas_Idle_Back_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.083, replaceable: true, flipped: false,
                                     repeatDelay: 3.6)
        addAnimation(north, named: .idle, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Gigas_Idle_Front_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.083, replaceable: true, flipped: false,
                                     repeatDelay: 3.6)
        addAnimation(south, named: .idle, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Gigas_Idle_Side_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                    repeatForever: true, waitings: [1: 3.4, images.count / 2 + 1: 3.4])
        addAnimation(east, named: .idle, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: true,
                                    repeatForever: true, waitings: [1: 3.4, images.count / 2 + 1: 3.4])
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Gigas_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Gigas_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Gigas_Walk_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `attack` animations.
    ///
    private func addAttack() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Gigas_Attack_Back_", first: 1, last: 10)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .attack, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Gigas_Attack_Front_", first: 1, last: 10)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .attack, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Gigas_Attack_Side_", first: 1, last: 10)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .attack, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .attack, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Gigas_Idle_Back_1"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Gigas_Idle_Front_1"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Gigas_Idle_Side_7"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
