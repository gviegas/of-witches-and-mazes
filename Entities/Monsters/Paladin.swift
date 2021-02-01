//
//  Paladin.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Paladin entity, a monster.
///
class Paladin: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return PaladinAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return PaladinAnimationSet.textureNames.union([PortraitSet.paladin.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = PaladinData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 2.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterAttackState(entity: self), .attack),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // AttackComponent
        let referenceShape = data.physicsShape
        let meleeDamage = Damage(scale: 1.6, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.45, .agility: 0.1, .faith: 0.3],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let quelling = Quelling(breakOnDamage: false, makeVulnerable: true, duration: 1.0)
        let quell = QuellCondition(quelling: quelling, source: self, color: nil, sfx: nil)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 48.0, broadness: 64.0,
                            delay: 0.2, duration: 0.1, conclusion: 0.5,
                            conditions: [quell], sfx: SoundFXSet.FX.attack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.hampering, .quelling]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Paladin` entity.
///
fileprivate class PaladinData: MonsterData {
    
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
        name = "Paladin"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .fast
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = PaladinProgressionValues.instance
        animationSet = PaladinAnimationSet()
        portrait = PortraitSet.paladin
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.femalePaladin, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Paladin` entity.
///
fileprivate class PaladinProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = PaladinProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 10, rate: 0.9),
            Ability.agility: ProgressionValue(initialValue: 5, rate: 0.45),
            Ability.intellect: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.faith: ProgressionValue(initialValue: 8, rate: 0.8)]
        
        let healthPointsValue = ProgressionValue(initialValue: 23, rate: 11.4)
        
        let defenseValue = ProgressionValue(initialValue: 40, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 10, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}
