//
//  Feral.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/28/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Feral entity, a monster.
///
class Feral: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return FeralAnimationSet.animationKeys.union(FeralRangedAttackAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return FeralAnimationSet.textureNames
            .union(FeralRangedAttackAnimation.textureNames)
            .union([PortraitSet.feral.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = FeralData(levelOfExperience: levelOfExperience)
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
        let rangedDamage = Damage(scale: 1.55, ratio: 0.25, level: levelOfExperience,
                                  modifiers: [:], type: .natural, sfx: SoundFXSet.FX.naturalHit)
        let rangedAnimation = FeralRangedAttackAnimation().animation
        let rangedAttack = Missile(medium: .power, range: 245.0, speed: 112.0,
                                   size: CGSize(width: 24.0, height: 24.0),
                                   delay: 0.1, conclusion: 1.65, dissipateOnHit: true,
                                   damage: rangedDamage, conditions: nil,
                                   animation: rangedAnimation,
                                   sfx: SoundFXSet.FX.naturalAttack)
        addComponent(MissileComponent(interaction: Interaction.monsterEffectOnObstacle, missile: rangedAttack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Feral` entity.
///
fileprivate class FeralData: MonsterData {
    
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
        name = "Feral"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .slow
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = FeralProgressionValues.instance
        animationSet = FeralAnimationSet()
        portrait = PortraitSet.feral
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.feral, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Feral` entity.
///
fileprivate class FeralProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = FeralProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 6, rate: 0.65),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.35),
            Ability.intellect: ProgressionValue(initialValue: 1, rate: 0.1),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 13, rate: 6.6)
        
        let defenseValue = ProgressionValue(initialValue: 5, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Feral`'s ranged attack.
///
fileprivate struct FeralRangedAttackAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Caustic_Projectile_Beginning_", first: 1, last: 10)
        let standard = ImageArray.createFrom(baseName: "Caustic_Projectile_", first: 1, last: 12)
        let end = ImageArray.createFrom(baseName: "Caustic_Projectile_End_", first: 1, last: 10)
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
        static let key = "FeralRangedAttackAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Caustic_Projectile_Beginning_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "FeralRangedAttackAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Caustic_Projectile_", first: 1, last: 12)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "FeralRangedAttackAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Caustic_Projectile_End_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
