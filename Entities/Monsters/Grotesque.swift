//
//  Grotesque.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/22/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Grotesque entity, a monster.
///
class Grotesque: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return GrotesqueAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return GrotesqueAnimationSet.textureNames.union([PortraitSet.grotesque.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = GrotesqueData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.5
        
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
        let meleeDamage = Damage(scale: 3.35, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.65],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 48.0, delay: 0.5, duration: 0.1, conclusion: 0.8,
                            conditions: nil, sfx: SoundFXSet.FX.brick)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Grotesque` entity.
///
fileprivate class GrotesqueData: MonsterData {
    
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
        name = "Grotesque"
        size = CGSize(width: 128.0, height: 128.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -48.0))
        progressionValues = GrotesqueProgressionValues.instance
        animationSet = GrotesqueAnimationSet()
        portrait = PortraitSet.grotesque
        shadow = (CGSize(width: 39.0, height: 26.0), "Shadow")
        voice = (SoundFXSet.Voice.goblin, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Grotesque` entity.
///
fileprivate class GrotesqueProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = GrotesqueProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 12, rate: 1.2),
            Ability.agility: ProgressionValue(initialValue: 4, rate: 0.5),
            Ability.intellect: ProgressionValue(initialValue: 1, rate: 0.15),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.15)]
        
        let healthPointsValue = ProgressionValue(initialValue: 26, rate: 13.3)
        
        let defenseValue = ProgressionValue(initialValue: 35, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
