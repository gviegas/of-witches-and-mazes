//
//  FlightlessMenaceAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `FlightlessMenace` entity.
///
class FlightlessMenaceAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Flightless Menace"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .rangedAttack, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Flightless_Menace_Idle_Back_", 1, 11),
            ("Flightless_Menace_Idle_Front_", 1, 11),
            ("Flightless_Menace_Idle_Side_", 1, 7),
            
            ("Flightless_Menace_Walk_Back_", 1, 10),
            ("Flightless_Menace_Walk_Front_", 1, 10),
            ("Flightless_Menace_Walk_Side_", 1, 10),
            
            ("Flightless_Menace_Attack_Back_", 1, 6),
            ("Flightless_Menace_Attack_Front_", 1, 6),
            ("Flightless_Menace_Attack_Side_", 1, 6)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: FlightlessMenaceAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addRangedAttack()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Flightless_Menace_Idle_Back_", first: 1, last: 11, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatDelay: 3.0)
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Flightless_Menace_Idle_Front_", first: 1, last: 11, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatDelay: 3.0)
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Flightless_Menace_Idle_Side_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true, waitings: [1: 3.0, images.count / 2 + 1: 3.0])
        addAnimation(east, named: .idle, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true, waitings: [1: 3.0, images.count / 2 + 1: 3.0])
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Flightless_Menace_Walk_Back_", first: 1, last: 10, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Flightless_Menace_Walk_Front_", first: 1, last: 10, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Flightless_Menace_Walk_Side_", first: 1, last: 10, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `rangedAttack` animations.
    ///
    private func addRangedAttack() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Flightless_Menace_Attack_Back_", first: 1, last: 6,
                                       reversing: true, dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false, waitings: [images.count / 2 + 1: 1.0])
        addAnimation(north, named: .rangedAttack, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Flightless_Menace_Attack_Front_", first: 1, last: 6,
                                       reversing: true, dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false, waitings: [images.count / 2 + 1: 1.0])
        addAnimation(south, named: .rangedAttack, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Flightless_Menace_Attack_Side_", first: 1, last: 6,
                                       reversing: true, dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false, waitings: [images.count / 2 + 1: 1.0])
        addAnimation(east, named: .rangedAttack, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false, waitings: [images.count / 2 + 1: 1.0])
        addAnimation(west, named: .rangedAttack, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Flightless_Menace_Idle_Back_1"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Flightless_Menace_Idle_Front_1"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Flightless_Menace_Idle_Side_7"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
