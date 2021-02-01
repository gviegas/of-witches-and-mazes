//
//  Rat.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/10/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Rat entity, a monster.
///
class Rat: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return RatAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return RatAnimationSet.textureNames.union([PortraitSet.rat.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = RatData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 0.45
        
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` associated with the `Rat` entity.
///
fileprivate class RatData: MonsterData {
    
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
        name = "Rat"
        size = CGSize(width: 32.0, height: 32.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 16.0, height: 16.0), center: CGPoint(x: 0, y: -8.0))
        progressionValues = RatProgressionValues.instance
        animationSet = RatAnimationSet()
        portrait = PortraitSet.rat
        shadow = (CGSize(width: 18.0, height: 12.0), "Shadow")
        voice = (SoundFXSet.Voice.tinyBeast, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Rat` entity.
///
fileprivate class RatProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = RatProgressionValues()
    
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
