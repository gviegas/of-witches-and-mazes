//
//  FlightlessMenace.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Flightless Menace entity, a monster.
///
class FlightlessMenace: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return FlightlessMenaceAnimationSet.animationKeys.union(FlightlessMenaceRangedAttackAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return FlightlessMenaceAnimationSet.textureNames
            .union(FlightlessMenaceRangedAttackAnimation.textureNames)
            .union([PortraitSet.flightlessMenace.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = FlightlessMenaceData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.0
        
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
        let rangedDamage = Damage(scale: 1.45, ratio: 0.2, level: levelOfExperience,
                                  modifiers: [:], type: .natural, sfx: SoundFXSet.FX.iceHit)
        let rangedConditions: [Condition] = [HamperCondition(slowFactor: 0.75, isExclusive: true,
                                                             isResettable: true, duration: 2.0,
                                                             source: self, color: nil, sfx: nil)]
        let rangedAnimation = FlightlessMenaceRangedAttackAnimation().animation
        let rangedAttack = Missile(medium: .power, range: 245.0, speed: 112.0,
                                   size: CGSize(width: 24.0, height: 24.0),
                                   delay: 0.3, conclusion: 1.85, dissipateOnHit: true,
                                   damage: rangedDamage, conditions: rangedConditions,
                                   animation: rangedAnimation,
                                   sfx: SoundFXSet.FX.ice)
        addComponent(MissileComponent(interaction: Interaction.monsterEffectOnObstacle, missile: rangedAttack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `FlightlessMenace` entity.
///
fileprivate class FlightlessMenaceData: MonsterData {
    
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
        name = "Flightless Menace"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .slow
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = FlightlessMenaceProgressionValues.instance
        animationSet = FlightlessMenaceAnimationSet()
        portrait = PortraitSet.flightlessMenace
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.bird, .high)}
}

/// The `EntityProgressionValues` subclass defining the progression values of the `FlightlessMenace` entity.
///
fileprivate class FlightlessMenaceProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = FlightlessMenaceProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 2, rate: 0.3),
            Ability.agility: ProgressionValue(initialValue: 2, rate: 0.25),
            Ability.intellect: ProgressionValue(initialValue: 1, rate: 0.1),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 13, rate: 6.4)
        
        let defenseValue = ProgressionValue(initialValue: 5, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `FlightlessMenace`'s ranged attack.
///
fileprivate struct FlightlessMenaceRangedAttackAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Glacial_Projectile_Beginning_", first: 1, last: 8)
        let standard = ImageArray.createFrom(baseName: "Glacial_Projectile_", first: 1, last: 8)
        let end = ImageArray.createFrom(baseName: "Glacial_Projectile_End_", first: 1, last: 8)
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
        static let key = "FlightlessMenaceRangedAttackAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Glacial_Projectile_Beginning_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "FlightlessMenaceRangedAttackAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Glacial_Projectile_", first: 1, last: 8, reversing: true)
            super.init(images: images, timePerFrame: 0.033, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "FlightlessMenaceRangedAttackAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Glacial_Projectile_End_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
