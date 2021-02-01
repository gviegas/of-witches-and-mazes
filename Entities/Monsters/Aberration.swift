//
//  Aberration.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Aberration entity, a monster.
///
class Aberration: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return AberrationAnimationSet.animationKeys.union(AberrationRangedAttackAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return AberrationAnimationSet.textureNames
            .union(AberrationRangedAttackAnimation.textureNames)
            .union([PortraitSet.aberration.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = AberrationData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.45
        
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
        let rangedDamage = Damage(scale: 2.4, ratio: 0.3, level: levelOfExperience,
                                  modifiers: [.intellect: 0.7],
                                  type: .magical, sfx: SoundFXSet.FX.darkHit)
        let rangedAnimation = AberrationRangedAttackAnimation().animation
        let rangedAttack = Missile(medium: .power, range: 245.0, speed: 160.0,
                                   size: CGSize(width: 24.0, height: 24.0),
                                   delay: 0.6, conclusion: 1.4, dissipateOnHit: true,
                                   damage: rangedDamage, conditions: nil,
                                   animation: rangedAnimation,
                                   sfx: SoundFXSet.FX.dark)
        addComponent(MissileComponent(interaction: Interaction.monsterEffectOnObstacle, missile: rangedAttack))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.curse, .weakness]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Aberration` entity.
///
fileprivate class AberrationData: MonsterData {
    
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
        name = "Aberration"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = AberrationProgressionValues.instance
        animationSet = AberrationAnimationSet()
        portrait = PortraitSet.aberration
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.cruelBeing, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Aberration` entity.
///
fileprivate class AberrationProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = AberrationProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 7, rate: 0.7),
            Ability.agility: ProgressionValue(initialValue: 4, rate: 0.35),
            Ability.intellect: ProgressionValue(initialValue: 11, rate: 1.0),
            Ability.faith: ProgressionValue(initialValue: 2, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 23, rate: 11.4)
        
        let defenseValue = ProgressionValue(initialValue: 20, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 50, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Aberration`'s ranged attack.
///
fileprivate struct AberrationRangedAttackAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Gloomy_Projectile_Beginning_", first: 1, last: 7)
        let standard = ImageArray.createFrom(baseName: "Gloomy_Projectile_", first: 1, last: 14)
        let end = ImageArray.createFrom(baseName: "Gloomy_Projectile_End_", first: 1, last: 11)
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
        static let key = "AberrationRangedAttackAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Gloomy_Projectile_Beginning_", first: 1, last: 7)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "AberrationRangedAttackAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Gloomy_Projectile_", first: 1, last: 14)
            super.init(images: images, timePerFrame: 0.035, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "AberrationRangedAttackAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Gloomy_Projectile_End_", first: 1, last: 11)
            super.init(images: images, timePerFrame: 0.033, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
