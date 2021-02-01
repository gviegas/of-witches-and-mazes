//
//  MermaidAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Mermaid` entity.
///
class MermaidAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Mermaid"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .cast, .castEnd, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Mermaid_Idle_Back_", 1, 6),
            ("Mermaid_Idle_Front_", 1, 6),
            ("Mermaid_Idle_Side_", 1, 6),
            
            ("Mermaid_Walk_Back_", 1, 11),
            ("Mermaid_Walk_Front_", 1, 11),
            ("Mermaid_Walk_Side_", 1, 11),
            
            ("Mermaid_Cast_Back_", 1, 13),
            ("Mermaid_Cast_Front_", 1, 13),
            ("Mermaid_Cast_Side_", 1, 13)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: MermaidAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addCast()
        addCastEnd()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Mermaid_Idle_Back_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatDelay: 4.0)
        addAnimation(north, named: .idle, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Mermaid_Idle_Front_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatDelay: 4.0)
        addAnimation(south, named: .idle, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Mermaid_Idle_Side_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatDelay: 4.0)
        addAnimation(east, named: .idle, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatDelay: 4.0)
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Mermaid_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Mermaid_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Mermaid_Walk_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `cast` animations.
    ///
    private func addCast() {
        var images = [String]()

        images = ImageArray.createFrom(baseName: "Mermaid_Cast_Back_", first: 1, last: 13)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .cast, forDirection: .north)

        images = ImageArray.createFrom(baseName: "Mermaid_Cast_Front_", first: 1, last: 13)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .cast, forDirection: .south)

        images = ImageArray.createFrom(baseName: "Mermaid_Cast_Side_", first: 1, last: 13)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .cast, forDirection: .east)

        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .cast, forDirection: .west)
    }
    
    /// Adds `castEnd` animations.
    ///
    private func addCastEnd() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Mermaid_Cast_Back_", first: 13, last: 1)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .castEnd, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Mermaid_Cast_Front_", first: 13, last: 1)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .castEnd, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Mermaid_Cast_Side_", first: 13, last: 1)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .castEnd, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .castEnd, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Mermaid_Idle_Back_6"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Mermaid_Idle_Front_6"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Mermaid_Idle_Side_6"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
