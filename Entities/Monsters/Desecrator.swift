//
//  Desecrator.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Desecrator entity, a monster.
///
class Desecrator: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return DesecratorAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return DesecratorAnimationSet.textureNames.union([PortraitSet.desecrator.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = DesecratorData(levelOfExperience: levelOfExperience)
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
        let meleeDamage = Damage(scale: 1.0, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.35, .agility: 0.15],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 32.0, delay: 0.35, duration: 0.1, conclusion: 0.6,
                            conditions: nil, sfx: SoundFXSet.FX.attack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Desecrator` entity.
///
fileprivate class DesecratorData: MonsterData {
    
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
        name = "Desecrator"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = DesecratorProgressionValues.instance
        animationSet = DesecratorAnimationSet()
        portrait = PortraitSet.desecrator
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.grimBeing, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Desecrator` entity.
///
fileprivate class DesecratorProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = DesecratorProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 7, rate: 0.8),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.6),
            Ability.intellect: ProgressionValue(initialValue: 3, rate: 0.5),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.15)]
        
        let healthPointsValue = ProgressionValue(initialValue: 17, rate: 8.4)
        
        let defenseValue = ProgressionValue(initialValue: 15, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
