//
//  AssassinAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/31/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Assassin` entity.
///
class AssassinAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Assassin"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .aim, .shoot, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Assassin_Idle_Back_", 1, 7),
            ("Assassin_Idle_Front_", 1, 7),
            ("Assassin_Idle_Side_", 1, 7),
            
            ("Assassin_Walk_Back_", 1, 11),
            ("Assassin_Walk_Front_", 1, 11),
            ("Assassin_Walk_Side_", 1, 11),
            
            ("Assassin_Aim_Back_", 1, 5),
            ("Assassin_Aim_Front_", 1, 5),
            ("Assassin_Aim_Side_", 1, 5),
            
            ("Assassin_Shoot_Back_", 1, 5),
            ("Assassin_Shoot_Front_", 1, 5),
            ("Assassin_Shoot_Side_", 1, 5)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: AssassinAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addAim()
        addShoot()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Assassin_Idle_Back_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 4.0, images.count / 2 + 1: 4.0])
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Assassin_Idle_Front_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 4.0, images.count / 2 + 1: 4.0])
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Assassin_Idle_Side_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true, waitings: [1: 4.0, images.count / 2 + 1: 4.0])
        addAnimation(east, named: .idle, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true, waitings: [1: 4.0, images.count / 2 + 1: 4.0])
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Assassin_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Assassin_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Assassin_Walk_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `aim` animations.
    ///
    private func addAim() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Assassin_Aim_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .aim, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Assassin_Aim_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .aim, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Assassin_Aim_Side_", first: 1, last: 5)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .aim, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .aim, forDirection: .west)
    }
    
    /// Adds `shoot` animations.
    ///
    private func addShoot() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Assassin_Shoot_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .shoot, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Assassin_Shoot_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .shoot, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Assassin_Shoot_Side_", first: 1, last: 5)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .shoot, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .shoot, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Assassin_Idle_Back_4"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Assassin_Idle_Front_4"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Assassin_Idle_Side_4"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
