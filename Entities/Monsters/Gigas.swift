//
//  Gigas.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Gigas entity, a monster.
///
class Gigas: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return GigasAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return GigasAnimationSet.textureNames.union([PortraitSet.gigas.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = GigasData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.6
        
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
        let meleeDamage = Damage(scale: 3.1, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.5, .agility: 0.2],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 48.0, delay: 0.3, duration: 0.1, conclusion: 0.4,
                            conditions: nil, sfx: SoundFXSet.FX.brick)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Gigas` entity.
///
fileprivate class GigasData: MonsterData {
    
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
        name = "Gigas"
        size = CGSize(width: 128.0, height: 128.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -48.0))
        progressionValues = GigasProgressionValues.instance
        animationSet = GigasAnimationSet()
        portrait = PortraitSet.gigas
        shadow = (CGSize(width: 39.0, height: 26.0), "Shadow")
        voice = (SoundFXSet.Voice.madBeast, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Gigas` entity.
///
fileprivate class GigasProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = GigasProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 13, rate: 1.4),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.65),
            Ability.intellect: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.faith: ProgressionValue(initialValue: 2, rate: 0.2)]

        let healthPointsValue = ProgressionValue(initialValue: 31, rate: 15.6)
        
        let defenseValue = ProgressionValue(initialValue: 40, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 10, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}
