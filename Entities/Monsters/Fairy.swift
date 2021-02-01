//
//  Fairy.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Fairy entity, a monster.
///
class Fairy: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return FairyAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return FairyAnimationSet.textureNames.union([PortraitSet.fairy.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = FairyData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterAttackState(entity: self), .attack),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // AttackComponent
        let referenceShape = data.physicsShape
        let meleeDamage = Damage(scale: 1.05, ratio: 0.1, level: levelOfExperience,
                                 modifiers: [.intellect: 0.25, .faith: 0.25],
                                 type: .magical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .power, damage: meleeDamage,
                            reach: 24.0, broadness: 24.0, delay: 0.3, duration: 0.1, conclusion: 0.3,
                            conditions: nil, sfx: SoundFXSet.FX.metal)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Fairy` entity.
///
fileprivate class FairyData: MonsterData {
    
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
        name = "Fairy"
        size = CGSize(width: 32.0, height: 32.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 16.0, height: 16.0), center: CGPoint(x: 0, y: -8.0))
        progressionValues = FairyProgressionValues.instance
        animationSet = FairyAnimationSet()
        portrait = PortraitSet.fairy
        shadow = (CGSize(width: 18.0, height: 12.0), "Shadow")
        voice = (SoundFXSet.Voice.youngFay, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Fairy` entity.
///
fileprivate class FairyProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = FairyProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 1, rate: 0.1),
            Ability.agility: ProgressionValue(initialValue: 8, rate: 0.85),
            Ability.intellect: ProgressionValue(initialValue: 5, rate: 0.6),
            Ability.faith: ProgressionValue(initialValue: 5, rate: 0.6)]
        
        let healthPointsValue = ProgressionValue(initialValue: 10, rate: 5.15)
        
        let defenseValue = ProgressionValue(initialValue: 20, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 25, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}
