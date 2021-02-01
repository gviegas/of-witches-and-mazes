//
//  LostLenoreAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `LostLenore` entity.
///
class LostLenoreAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Lost Lenore"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .lift, .hold, .carry, .hurl, .attack, .use, .useEnd,
                                         .cast, .castEnd]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Lost_Lenore_Idle_Back_", 1, 6),
            ("Lost_Lenore_Idle_Front_", 1, 6),
            ("Lost_Lenore_Idle_Side_", 1, 6),
            
            ("Lost_Lenore_Walk_Back_", 1, 11),
            ("Lost_Lenore_Walk_Front_", 1, 11),
            ("Lost_Lenore_Walk_Side_", 1, 11),
            
            ("Lost_Lenore_Lift_Back_", 1, 6),
            ("Lost_Lenore_Lift_Front_", 1, 6),
            ("Lost_Lenore_Lift_Side_", 1, 6),
            
            ("Lost_Lenore_Carry_Back_", 1, 11),
            ("Lost_Lenore_Carry_Front_", 1, 11),
            ("Lost_Lenore_Carry_Side_", 1, 11),
            
            ("Lost_Lenore_Hurl_Back_", 1, 6),
            ("Lost_Lenore_Hurl_Front_", 1, 6),
            ("Lost_Lenore_Hurl_Side_", 1, 6),
            
            ("Lost_Lenore_Attack_Back_", 1, 10),
            ("Lost_Lenore_Attack_Front_", 1, 10),
            ("Lost_Lenore_Attack_Side_", 1, 10),
            
            ("Lost_Lenore_Use_Back_", 1, 6),
            ("Lost_Lenore_Use_Front_", 1, 6),
            ("Lost_Lenore_Use_Side_", 1, 6),
            
            ("Lost_Lenore_Cast_Back_", 1, 10),
            ("Lost_Lenore_Cast_Front_", 1, 10),
            ("Lost_Lenore_Cast_Side_", 1, 10)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: LostLenoreAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addLift()
        addHold()
        addCarry()
        addHurl()
        addAttack()
        addUse()
        addUseEnd()
        addCast()
        addCastEnd()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Idle_Back_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 4.0])
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Idle_Front_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 4.0])
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Idle_Side_", first: 1, last: 6, reversing: true,
                                       dropFirst: false)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true, waitings: [1: 4.0])
        addAnimation(east, named: .idle, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true, waitings: [1: 4.0])
        addAnimation(west, named: .idle, forDirection: .west)
    }
    
    /// Adds `walk` animations.
    ///
    private func addWalk() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Walk_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .walk, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .walk, forDirection: .west)
    }
    
    /// Adds `lift` animations.
    ///
    private func addLift() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Lift_Back_", first: 1, last: 6)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .lift, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Lift_Front_", first: 1, last: 6)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .lift, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Lift_Side_", first: 1, last: 6)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .lift, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .lift, forDirection: .west)
    }
    
    /// Adds `hold` animations.
    ///
    private func addHold() {
        var images = [String]()
        
        images = ["Lost_Lenore_Lift_Back_6"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .hold, forDirection: .north)
        
        images = ["Lost_Lenore_Lift_Front_6"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .hold, forDirection: .south)
        
        images = ["Lost_Lenore_Lift_Side_6"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .hold, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .hold, forDirection: .west)
    }
    
    /// Adds `carry` animations.
    ///
    private func addCarry() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Carry_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .carry, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Carry_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .carry, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Carry_Side_", first: 1, last: 11, reversing: true)
        let east = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                    repeatForever: true)
        addAnimation(east, named: .carry, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: true,
                                    repeatForever: true)
        addAnimation(west, named: .carry, forDirection: .west)
    }
    
    /// Adds `hurl` animations.
    ///
    private func addHurl() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Hurl_Back_", first: 1, last: 6)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .hurl, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Hurl_Front_", first: 1, last: 6)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .hurl, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Hurl_Side_", first: 1, last: 6)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .hurl, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .hurl, forDirection: .west)
    }
    
    /// Adds `attack` animations.
    ///
    private func addAttack() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Attack_Back_", first: 1, last: 10)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .attack, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Attack_Front_", first: 1, last: 10)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .attack, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Attack_Side_", first: 1, last: 10)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .attack, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .attack, forDirection: .west)
    }
    
    /// Adds `use` animations.
    ///
    private func addUse() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Use_Back_", first: 1, last: 6)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .use, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Use_Front_", first: 1, last: 6)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .use, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Use_Side_", first: 1, last: 6)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .use, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .use, forDirection: .west)
    }
    
    /// Adds `useEnd` animations.
    ///
    private func addUseEnd() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Use_Back_", first: 6, last: 1)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .useEnd, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Use_Front_", first: 6, last: 1)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .useEnd, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Use_Side_", first: 6, last: 1)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .useEnd, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .useEnd, forDirection: .west)
    }
    
    /// Adds `cast` animations.
    ///
    private func addCast() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Cast_Back_", first: 1, last: 10)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .cast, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Cast_Front_", first: 1, last: 10)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .cast, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Cast_Side_", first: 1, last: 10)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .cast, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .cast, forDirection: .west)
    }
    
    /// Adds `castEnd` animations.
    ///
    private func addCastEnd() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Cast_Back_", first: 10, last: 1)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .castEnd, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Cast_Front_", first: 10, last: 1)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .castEnd, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Lost_Lenore_Cast_Side_", first: 10, last: 1)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .castEnd, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .castEnd, forDirection: .west)
    }
}
