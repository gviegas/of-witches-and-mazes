//
//  TheraxyanAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Theraxyan` entity.
///
class TheraxyanAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Theraxyan"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .causeRay, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Theraxyan_Idle_Back_", 1, 6),
            ("Theraxyan_Idle_Front_", 1, 6),
            ("Theraxyan_Idle_Side_", 1, 6),
            
            ("Theraxyan_Walk_Back_", 1, 11),
            ("Theraxyan_Walk_Front_", 1, 11),
            ("Theraxyan_Walk_Side_", 1, 11),
            
            ("Theraxyan_Cast_Back_", 1, 10),
            ("Theraxyan_Cast_Front_", 1, 10),
            ("Theraxyan_Cast_Side_", 1, 10)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: TheraxyanAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addCauseRay()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Theraxyan_Idle_Back_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 3.0, images.count / 2 + 1: 3.0])
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Theraxyan_Idle_Front_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 3.0, images.count / 2 + 1: 3.0])
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Theraxyan_Idle_Side_", first: 1, last: 6, reversing: true,
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
        
        images = ImageArray.createFrom(baseName: "Theraxyan_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Theraxyan_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Theraxyan_Walk_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `causeRay` animations.
    ///
    private func addCauseRay() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Theraxyan_Cast_Back_", first: 1, last: 10)
        let north = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                     repeatForever: false, waitings: [4: 0.33, 7: 0.33])
        addAnimation(north, named: .causeRay, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Theraxyan_Cast_Front_", first: 1, last: 10)
        let south = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                     repeatForever: false, waitings: [4: 0.33, 7: 0.33])
        addAnimation(south, named: .causeRay, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Theraxyan_Cast_Side_", first: 1, last: 10)
        let east = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                    repeatForever: false, waitings: [4: 0.33, 7: 0.33])
        addAnimation(east, named: .causeRay, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: true,
                                    repeatForever: false, waitings: [4: 0.33, 7: 0.33])
        addAnimation(west, named: .causeRay, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Theraxyan_Idle_Back_1"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Theraxyan_Idle_Front_1"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Theraxyan_Idle_Side_1"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
