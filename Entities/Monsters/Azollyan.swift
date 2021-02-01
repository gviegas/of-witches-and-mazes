//
//  Azollyan.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/18/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Azollyan entity, a monster.
///
class Azollyan: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return AzollyanAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return AzollyanAnimationSet.textureNames.union([PortraitSet.azollyan.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = AzollyanData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.15
        
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
        let meleeDamage = Damage(scale: 1.25, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.4, .agility: 0.25],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 32.0, delay: 0.35, duration: 0.1, conclusion: 0.5,
                            conditions: nil, sfx: SoundFXSet.FX.attack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Azollyan` entity.
///
fileprivate class AzollyanData: MonsterData {
    
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
        name = "Azollyan"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = AzollyanProgressionValues.instance
        animationSet = AzollyanAnimationSet()
        portrait = PortraitSet.azollyan
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.malePaladin, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Azollyan` entity.
///
fileprivate class AzollyanProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = AzollyanProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 8, rate: 0.8),
            Ability.agility: ProgressionValue(initialValue: 7, rate: 0.65),
            Ability.intellect: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.faith: ProgressionValue(initialValue: 4, rate: 0.4)]
        
        let healthPointsValue = ProgressionValue(initialValue: 21, rate: 10.2)
        
        let defenseValue = ProgressionValue(initialValue: 30, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
