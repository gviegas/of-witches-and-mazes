//
//  Theraxyan.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Theraxyan entity, a monster.
///
class Theraxyan: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return TheraxyanAnimationSet.animationKeys.union(TheraxyanRayAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return TheraxyanAnimationSet.textureNames
            .union(TheraxyanRayAnimation.textureNames)
            .union([PortraitSet.theraxyan.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = TheraxyanData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.4
        
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
        let rayDamage = Damage(scale: 2.4, ratio: 0.25, level: levelOfExperience,
                               modifiers: [.intellect: 0.3, .faith: 0.45],
                               type: .magical, sfx: SoundFXSet.FX.energyHit)
        let rayConditions = [SoftenCondition(damageTakenIncrease: 0.5, isExclusive: true, isResettable: true,
                                             duration: 8.0, source: self, color: nil, sfx: nil)]
        let rayAnimation = TheraxyanRayAnimation().animation
        let ray = Ray(medium: .power,
                      initialSize: CGSize(width: 0, height: 24.0),
                      finalSize: CGSize(width: 320.0, height: 24.0),
                      delay: 0.5, duration: rayAnimation.1?.duration ?? 0.5, conclusion: 0.8,
                      damage: rayDamage, conditions: rayConditions,
                      animation: rayAnimation,
                      sfx: SoundFXSet.FX.energy)
        addComponent(RayComponent(interaction: Interaction.monsterEffect, ray: ray))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Theraxyan` entity.
///
fileprivate class TheraxyanData: MonsterData {
    
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
        name = "Theraxyan"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = TheraxyanProgressionValues.instance
        animationSet = TheraxyanAnimationSet()
        portrait = PortraitSet.theraxyan
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.oldBeing, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Theraxyan` entity.
///
fileprivate class TheraxyanProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = TheraxyanProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 7, rate: 0.8),
            Ability.agility: ProgressionValue(initialValue: 5, rate: 0.55),
            Ability.intellect: ProgressionValue(initialValue: 7, rate: 0.8),
            Ability.faith: ProgressionValue(initialValue: 8, rate: 0.85)]
        
        let healthPointsValue = ProgressionValue(initialValue: 23, rate: 11.7)
        
        let defenseValue = ProgressionValue(initialValue: 30, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 30, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Theraxyan`'s ray.
///
fileprivate struct TheraxyanRayAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Scarlet_Beam_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Scarlet_Beam_", first: 1, last: 8)
        let end = ImageArray.createFrom(baseName: "Scarlet_Beam_End_", first: 1, last: 4)
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
        static let key = "TheraxyanRayAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Scarlet_Beam_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "TheraxyanRayAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Scarlet_Beam_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "TheraxyanRayAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Scarlet_Beam_End_", first: 1, last: 4)
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0, y: 0.5)
            super.play(node: node)
        }
    }
}
