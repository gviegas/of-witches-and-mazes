//
//  Witch.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/13/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Witch entity, a monster.
///
class Witch: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return WitchAnimationSet.animationKeys.union(WitchRangedAttackAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return WitchAnimationSet.textureNames
            .union(WitchRangedAttackAnimation.textureNames)
            .union([PortraitSet.witch.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = WitchData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.3
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterRangedAttackState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // MissileComponent
        let curse = CurseCondition(reductionFactor: 0.25, isExclusive: false, isResettable: true,
                                   duration: 60.0, source: self)
        let rangedAnimation = WitchRangedAttackAnimation().animation
        let rangedAttack = Missile(medium: .spell, range: 245.0, speed: 112.0,
                                   size: CGSize(width: 24.0, height: 24.0),
                                   delay: 0.7, conclusion: 1.5, dissipateOnHit: true,
                                   damage: nil, conditions: [curse],
                                   animation: rangedAnimation,
                                   sfx: SoundFXSet.FX.curse)
        addComponent(MissileComponent(interaction: Interaction.monsterEffectOnObstacle, missile: rangedAttack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Witch` entity.
///
fileprivate class WitchData: MonsterData {
    
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
        name = "Witch"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = WitchProgressionValues.instance
        animationSet = WitchAnimationSet()
        portrait = PortraitSet.witch
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.witch, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Witch` entity.
///
fileprivate class WitchProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = WitchProgressionValues()
    
    private init() {
        let abilityValues = [Ability.strength: ProgressionValue(initialValue: 2, rate: 0.3),
                             Ability.agility: ProgressionValue(initialValue: 3, rate: 0.35),
                             Ability.intellect: ProgressionValue(initialValue: 12, rate: 1.2),
                             Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 12, rate: 5.75)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 20, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Witch`'s ranged attack.
///
fileprivate struct WitchRangedAttackAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Dread_Projectile_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Dread_Projectile_", first: 1, last: 6, reversing: true)
        let end = ImageArray.createFrom(baseName: "Dread_Projectile_End_", first: 1, last: 6)
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
        static let key = "WitchRangedAttackAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Dread_Projectile_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "WitchRangedAttackAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Dread_Projectile_", first: 1, last: 6, reversing: true)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "WitchRangedAttackAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Dread_Projectile_End_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
