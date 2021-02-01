//
//  WizardAnimationSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DirectionalAnimationSet` subclass for the `Wizard` entity.
///
class WizardAnimationSet: DirectionalAnimationSet, TextureUser, AnimationUser {
    
    /// The identifier to be used when creating the object.
    ///
    private static let _identifier = "Wizard"
    
    static var animationKeys: Set<String> {
        let names: Set<AnimationName> = [.idle, .walk, .lift, .hold, .carry, .hurl, .attack, .aim, .shoot, .direct,
                                         .toss, .use, .useEnd, .cast, .castEnd, .quell]
        return DirectionalAnimationSet.makeKeysForAllDirections(identifier: _identifier, names: names)
    }
    
    static var textureNames: Set<String> {
        let frames: [(name: String, first: Int, last: Int)] = [
            ("Wizard_Idle_Back_", 1, 7),
            ("Wizard_Idle_Front_", 1, 7),
            ("Wizard_Idle_Side_", 1, 7),
            
            ("Wizard_Walk_Back_", 1, 11),
            ("Wizard_Walk_Front_", 1, 11),
            ("Wizard_Walk_Side_", 1, 11),
            
            ("Wizard_Lift_Back_", 1, 5),
            ("Wizard_Lift_Front_", 1, 5),
            ("Wizard_Lift_Side_", 1, 5),
            
            ("Wizard_Carry_Back_", 1, 11),
            ("Wizard_Carry_Front_", 1, 11),
            ("Wizard_Carry_Side_", 1, 11),
            
            ("Wizard_Hurl_Back_", 1, 5),
            ("Wizard_Hurl_Front_", 1, 5),
            ("Wizard_Hurl_Side_", 1, 5),
            
            ("Wizard_Attack_Back_", 1, 7),
            ("Wizard_Attack_Front_", 1, 7),
            ("Wizard_Attack_Side_", 1, 7),
            
            ("Wizard_Aim_Back_", 1, 5),
            ("Wizard_Aim_Front_", 1, 5),
            ("Wizard_Aim_Side_", 1, 5),
            
            ("Wizard_Shoot_Back_", 1, 5),
            ("Wizard_Shoot_Front_", 1, 5),
            ("Wizard_Shoot_Side_", 1, 5),
            
            ("Wizard_Direct_Back_", 1, 5),
            ("Wizard_Direct_Front_", 1, 5),
            ("Wizard_Direct_Side_", 1, 5),
            
            ("Wizard_Toss_Back_", 1, 5),
            ("Wizard_Toss_Front_", 1, 5),
            ("Wizard_Toss_Side_", 1, 5),
            
            ("Wizard_Use_Back_", 1, 5),
            ("Wizard_Use_Front_", 1, 5),
            ("Wizard_Use_Side_", 1, 5),
            
            ("Wizard_Cast_Back_", 1, 7),
            ("Wizard_Cast_Front_", 1, 7),
            ("Wizard_Cast_Side_", 1, 7)]
        
        return frames.reduce(Set<String>()) { (result, frame) in
            let (name, first, last) = frame
            return result.union(ImageArray.createFrom(baseName: name, first: first, last: last))
        }
    }
    
    /// Creates a new instance.
    ///
    init() {
        super.init(identifier: WizardAnimationSet._identifier)
        
        addIdle()
        addWalk()
        addLift()
        addHold()
        addCarry()
        addHurl()
        addAttack()
        addAim()
        addShoot()
        addDirect()
        addToss()
        addUse()
        addUseEnd()
        addCast()
        addCastEnd()
        addQuell()
    }
    
    /// Adds `idle` animations.
    ///
    private func addIdle() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Wizard_Idle_Back_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 4.0, images.count / 2 + 1: 4.0])
        addAnimation(north, named: .idle, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Idle_Front_", first: 1, last: 7, reversing: true,
                                       dropFirst: false)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true, waitings: [1: 4.0, images.count / 2 + 1: 4.0])
        addAnimation(south, named: .idle, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Idle_Side_", first: 1, last: 7, reversing: true,
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Walk_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .walk, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Walk_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .walk, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Walk_Side_", first: 1, last: 11, reversing: true)
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Lift_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .lift, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Lift_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .lift, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Lift_Side_", first: 1, last: 5)
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
        
        images = ["Wizard_Lift_Back_5"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .hold, forDirection: .north)
        
        images = ["Wizard_Lift_Front_5"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .hold, forDirection: .south)
        
        images = ["Wizard_Lift_Side_5"]
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Carry_Back_", first: 1, last: 11, reversing: true)
        let north = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(north, named: .carry, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Carry_Front_", first: 1, last: 11, reversing: true)
        let south = TextureAnimation(images: images, timePerFrame: 0.067, replaceable: true, flipped: false,
                                     repeatForever: true)
        addAnimation(south, named: .carry, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Carry_Side_", first: 1, last: 11, reversing: true)
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Hurl_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .hurl, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Hurl_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .hurl, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Hurl_Side_", first: 1, last: 5)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .hurl, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .hurl, forDirection: .west)
    }
    
    /// Adds `attack` animations.
    ///
    private func addAttack() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Wizard_Attack_Back_", first: 1, last: 7)
        let north = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .attack, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Attack_Front_", first: 1, last: 7)
        let south = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .attack, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Attack_Side_", first: 1, last: 7)
        let east = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .attack, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.017, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .attack, forDirection: .west)
    }
    
    /// Adds `aim` animations.
    ///
    private func addAim() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Wizard_Aim_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .aim, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Aim_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .aim, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Aim_Side_", first: 1, last: 5)
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Shoot_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .shoot, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Shoot_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .shoot, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Shoot_Side_", first: 1, last: 5)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .shoot, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .shoot, forDirection: .west)
    }
    
    /// Adds `direct` animations.
    ///
    private func addDirect() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Wizard_Direct_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .direct, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Direct_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .direct, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Direct_Side_", first: 1, last: 5)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .direct, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .direct, forDirection: .west)
    }
    
    /// Adds `toss` animations.
    ///
    private func addToss() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Wizard_Toss_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .toss, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Toss_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .toss, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Toss_Side_", first: 1, last: 5)
        let east = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .toss, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.033, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .toss, forDirection: .west)
    }
    
    /// Adds `use` animations.
    ///
    private func addUse() {
        var images = [String]()
        
        images = ImageArray.createFrom(baseName: "Wizard_Use_Back_", first: 1, last: 5)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .use, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Use_Front_", first: 1, last: 5)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .use, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Use_Side_", first: 1, last: 5)
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Use_Back_", first: 5, last: 1)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .useEnd, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Use_Front_", first: 5, last: 1)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .useEnd, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Use_Side_", first: 5, last: 1)
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Cast_Back_", first: 1, last: 7)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .cast, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Cast_Front_", first: 1, last: 7)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .cast, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Cast_Side_", first: 1, last: 7)
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
        
        images = ImageArray.createFrom(baseName: "Wizard_Cast_Back_", first: 7, last: 1)
        let north = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .castEnd, forDirection: .north)
        
        images = ImageArray.createFrom(baseName: "Wizard_Cast_Front_", first: 7, last: 1)
        let south = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .castEnd, forDirection: .south)
        
        images = ImageArray.createFrom(baseName: "Wizard_Cast_Side_", first: 7, last: 1)
        let east = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .castEnd, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 0.05, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .castEnd, forDirection: .west)
    }
    
    /// Adds `quell` animations.
    ///
    private func addQuell() {
        var images = [String]()
        
        images = ["Wizard_Idle_Back_7"]
        let north = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(north, named: .quell, forDirection: .north)
        
        images = ["Wizard_Idle_Front_7"]
        let south = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                     repeatForever: false)
        addAnimation(south, named: .quell, forDirection: .south)
        
        images = ["Wizard_Idle_Side_7"]
        let east = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: false,
                                    repeatForever: false)
        addAnimation(east, named: .quell, forDirection: .east)
        
        let west = TextureAnimation(images: images, timePerFrame: 1.0, replaceable: true, flipped: true,
                                    repeatForever: false)
        addAnimation(west, named: .quell, forDirection: .west)
    }
}
