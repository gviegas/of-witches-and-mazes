//
//  Beetle.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Beetle entity, a monster.
///
class Beetle: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return BeetleAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return BeetleAnimationSet.textureNames.union([PortraitSet.beetle.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = BeetleData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 0.4
        
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
        let meleeDamage = Damage(scale: 0.5, ratio: 0.25, level: levelOfExperience,
                                 modifiers: [.strength: 0.3],
                                 type: .physical, sfx: SoundFXSet.FX.weakHit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 24.0, broadness: 24.0, delay: 0.4, duration: 0.1, conclusion: 0.5,
                            conditions: nil, sfx: SoundFXSet.FX.weakAttack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Beetle` entity.
///
fileprivate class BeetleData: MonsterData {
    
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
        name = "Beetle"
        size = CGSize(width: 32.0, height: 32.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 16.0, height: 16.0), center: CGPoint(x: 0, y: -8.0))
        progressionValues = BeetleProgressionValues.instance
        animationSet = BeetleAnimationSet()
        portrait = PortraitSet.beetle
        shadow = (CGSize(width: 18.0, height: 12.0), "Shadow")
        voice = (SoundFXSet.Voice.insect, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Beetle` entity.
///
fileprivate class BeetleProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = BeetleProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 2, rate: 0.3),
            Ability.agility: ProgressionValue(initialValue: 1, rate: 0.25),
            Ability.intellect: ProgressionValue(initialValue: 0, rate: 0),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 6, rate: 3.1)
        
        let defenseValue = ProgressionValue(initialValue: 5, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
