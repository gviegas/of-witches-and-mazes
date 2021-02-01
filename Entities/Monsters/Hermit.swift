//
//  Hermit.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Hermit entity, a monster.
///
class Hermit: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return HermitAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return HermitAnimationSet.textureNames.union([PortraitSet.hermit.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = HermitData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 0.9
        
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
        let meleeDamage = Damage(scale: 1.0, ratio: 0.3, level: levelOfExperience,
                                 modifiers: [.strength: 0.3, .agility: 0.15],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 32.0, delay: 0.3, duration: 0.1, conclusion: 0.6,
                            conditions: nil, sfx: SoundFXSet.FX.attack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Hermit` entity.
///
fileprivate class HermitData: MonsterData {
    
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
        name = "Hermit"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = HermitProgressionValues.instance
        animationSet = HermitAnimationSet()
        portrait = PortraitSet.hermit
        shadow = (CGSize(width: 42.0, height: 28.0), "Shadow")
        voice = (SoundFXSet.Voice.toad, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Hermit` entity.
///
fileprivate class HermitProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = HermitProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 5, rate: 0.6),
            Ability.agility: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.intellect: ProgressionValue(initialValue: 0, rate: 0),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 10, rate: 5.3)
        
        let defenseValue = ProgressionValue(initialValue: 15, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
