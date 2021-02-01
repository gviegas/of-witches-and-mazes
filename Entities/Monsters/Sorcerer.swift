//
//  Sorcerer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Sorcerer entity, a monster.
///
class Sorcerer: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return SorcererAnimationSet.animationKeys.union(SorcererRayAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return SorcererAnimationSet.textureNames
            .union(SorcererRayAnimation.textureNames)
            .union([PortraitSet.sorcerer.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = SorcererData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.1
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterRayState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // RayComponent
        let damage = Damage(scale: 1.2, ratio: 0.25, level: levelOfExperience, modifiers: [.intellect: 0.5],
                            type: .magical, sfx: SoundFXSet.FX.iceHit)
        let condition = HamperCondition(slowFactor: 0.5, isExclusive: true, isResettable: true, duration: 6.0,
                                        source: nil, color: nil, sfx: nil)
        let animation = SorcererRayAnimation().animation
        let ray = Ray(medium: .spell,
                      initialSize: CGSize(width: 0, height: 24.0),
                      finalSize: CGSize(width: 320.0, height: 24.0),
                      delay: (animation.0?.duration ?? 0.5) + 0.5,
                      duration: animation.1?.duration ?? 0.5,
                      conclusion: (animation.2?.duration ?? 0.5) + 1.0,
                      damage: damage, conditions: [condition],
                      animation: animation,
                      sfx: SoundFXSet.FX.ice)
        addComponent(RayComponent(interaction: .monsterEffect, ray: ray))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Sorcerer` entity.
///
fileprivate class SorcererData: MonsterData {
    
    let name: String
    let size: CGSize
    let speed: MovementSpeed
    let physicsShape: PhysicsShape
    let progressionValues: EntityProgressionValues
    let animationSet: DirectionalAnimationSet
    let portrait: Portrait
    let shadow: (size: CGSize, image: String)?
    let voice: (sound: SoundFX, volubleness: VoiceComponent.Volubleness)?
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Sorcerer"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = SorcererProgressionValues.instance
        animationSet = SorcererAnimationSet()
        portrait = PortraitSet.sorcerer
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.sorcerer, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Sorcerer` entity.
///
fileprivate class SorcererProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = SorcererProgressionValues()
    
    private init() {
        let abilityValues = [Ability.strength: ProgressionValue(initialValue: 3, rate: 0.3),
                             Ability.agility: ProgressionValue(initialValue: 3, rate: 0.3),
                             Ability.intellect: ProgressionValue(initialValue: 11, rate: 1.0),
                             Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 11, rate: 5.7)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 15, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct that defines the animations for the `Sorcerer`'s ray.
///
fileprivate struct SorcererRayAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Azure_Beam_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Azure_Beam_", first: 1, last: 8)
        let end = ImageArray.createFrom(baseName: "Azure_Beam_End_", first: 1, last: 4)
        return Set<String>(beginning + standard + end)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let beginning = AnimationSource.getAnimation(forKey: Beginning.key) ?? Beginning()
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (beginning, standard, end)
    }
    
    private class Beginning: TextureAnimation {
        static let key = "SorcererRayAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Azure_Beam_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "SorcererRayAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Azure_Beam_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "SorcererRayAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Azure_Beam_End_", first: 1, last: 4)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
}
