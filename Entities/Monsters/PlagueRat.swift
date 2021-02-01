//
//  PlagueRat.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Plague Rat entity, a monster.
///
class PlagueRat: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return PlagueRatAnimationSet.animationKeys.union(PlagueRatAuraAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return PlagueRatAnimationSet.textureNames
            .union(PlagueRatAuraAnimation.textureNames)
            .union([PortraitSet.plagueRat.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = PlagueRatData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 0.8
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterAttackState(entity: self), .attack),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .inferior, level: levelOfExperience)))
        
        // AttackComponent
        let referenceShape = data.physicsShape
        let meleeDamage = Damage(scale: 0.65, ratio: 0.25, level: levelOfExperience,
                                 modifiers: [.strength: 0.1, .agility: 0.3],
                                 type: .physical, sfx: SoundFXSet.FX.weakHit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 24.0, broadness: 24.0, delay: 0.4, duration: 0.1, conclusion: 0.4,
                            conditions: nil, sfx: SoundFXSet.FX.weakAttack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
        
        // AuraComponent
        let interval = 2.5
        let duration = interval + 1.0 / 30.0
        let damage = Damage(scale: 0.25, ratio: 0, level: levelOfExperience, modifiers: [:], type: .natural, sfx: nil)
        let dot = PoisonCondition(tickTime: interval, tickDamage: damage, isExclusive: false,
                                  isResettable: true, duration: duration, source: self)
        let aura = Aura(radius: 36.0, refreshTime: interval, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: nil, conditions: [dot], animation: PlagueRatAuraAnimation.instance,
                        sfx: nil)
        addComponent(AuraComponent(interaction: Interaction.monsterEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `PlagueRat` entity.
///
fileprivate class PlagueRatData: MonsterData {
    
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
        name = "Plague Rat"
        size = CGSize(width: 32.0, height: 32.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 16.0, height: 16.0), center: CGPoint(x: 0, y: -8.0))
        progressionValues = PlagueRatProgressionValues.instance
        animationSet = PlagueRatAnimationSet()
        portrait = PortraitSet.plagueRat
        shadow = (CGSize(width: 18.0, height: 12.0), "Shadow")
        voice = (SoundFXSet.Voice.tinyBeast, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `PlagueRat` entity.
///
fileprivate class PlagueRatProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = PlagueRatProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 1, rate: 0.2),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.7),
            Ability.intellect: ProgressionValue(initialValue: 0, rate: 0),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 7, rate: 3.85)
        
        let defenseValue = ProgressionValue(initialValue: 5, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}

/// The `TextureAnimation` subclass defining the animation for the `PlagueRat`'s aura.
///
fileprivate class PlagueRatAuraAnimation: TextureAnimation, TextureUser, AnimationUser {
    private static let key = "PlagueRatAuraAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    static var textureNames: Set<String> {
        let plague = ImageArray.createFrom(baseName: "Plague_", first: 1, last: 8)
        return Set<String>(plague)
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? PlagueRatAuraAnimation()
    }
    
    private init() {
        let images = ImageArray.createFrom(baseName: "Plague_", first: 1, last: 8)
        super.init(images: images, timePerFrame: 0.083, replaceable: false, flipped: false, repeatForever: true)
        AnimationSource.storeAnimation(self, forKey: PlagueRatAuraAnimation.key)
    }
}
