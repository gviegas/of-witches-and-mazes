//
//  Spectre.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Spectre entity, a monster.
///
class Spectre: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return SpectreAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return SpectreAnimationSet.textureNames.union([PortraitSet.spectre.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = SpectreData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.3
        
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
        let meleeDamage = Damage(scale: 1.2, ratio: 0.15, level: levelOfExperience,
                                 modifiers: [.intellect: 0.45],
                                 type: .spiritual, sfx: SoundFXSet.FX.hit)
        let hamper = HamperCondition(slowFactor: 0.65, isExclusive: true, isResettable: true, duration: 3.0,
                                     source: self, color: nil, sfx: nil)
        let attack = Attack(medium: .power, damage: meleeDamage,
                            reach: 32.0, broadness: 32.0, delay: 0.35, duration: 0.1, conclusion: 0.55,
                            conditions: [hamper], sfx: SoundFXSet.FX.boiling)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.poison, .hampering]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Spectre` entity.
///
fileprivate class SpectreData: MonsterData {
    
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
        name = "Spectre"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = SpectreProgressionValues.instance
        animationSet = SpectreAnimationSet()
        portrait = PortraitSet.spectre
        shadow = (CGSize(width: 27.0, height: 18.0), "Shadow")
        voice = (SoundFXSet.Voice.spectre, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Spectre` entity.
///
fileprivate class SpectreProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = SpectreProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 3, rate: 0.35),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.35),
            Ability.intellect: ProgressionValue(initialValue: 9, rate: 0.9),
            Ability.faith: ProgressionValue(initialValue: 4, rate: 0.5)]
        
        let healthPointsValue = ProgressionValue(initialValue: 19, rate: 9.7)
        
        let defenseValue = ProgressionValue(initialValue: 25, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 35, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}
