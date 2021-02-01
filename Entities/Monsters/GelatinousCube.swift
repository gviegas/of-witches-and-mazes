//
//  GelatinousCube.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Gelatinous Cube entity, a monster.
///
class GelatinousCube: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return GelatinousCubeAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return GelatinousCubeAnimationSet.textureNames.union([PortraitSet.gelatinousCube.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = GelatinousCubeData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.8
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterStayState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // AuraComponent
        let damage = Damage(scale: 4.15, ratio: 0.1, level: levelOfExperience, modifiers: [:], type: .natural,
                            sfx: SoundFXSet.FX.naturalHit)
        let radius = min(data.size.width, data.size.height) / 2.0
        let aura = Aura(radius: radius, refreshTime: 1.0, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: damage, conditions: nil, animation: nil, sfx: nil)
        addComponent(AuraComponent(interaction: Interaction.monsterEffect, aura: aura))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.curse, .hampering, .quelling]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` of the `GelatinousCube` entity.
///
fileprivate class GelatinousCubeData: MonsterData {
    
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
        name = "Gelatinous Cube"
        size = CGSize(width: 128.0, height: 128.0)
        speed = .verySlow
        physicsShape = .rectangle(size: CGSize(width: 48.0, height: 48.0), center: CGPoint(x: 0, y: -40.0))
        progressionValues = GelatinousCubeProgressionValues.instance
        animationSet = GelatinousCubeAnimationSet()
        portrait = PortraitSet.gelatinousCube
        shadow = (CGSize(width: 120.0, height: 80.0), "Shadow")
        voice = nil
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `GelatinousCube` entity.
///
fileprivate class GelatinousCubeProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = GelatinousCubeProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 21, rate: 2.0),
            Ability.agility: ProgressionValue(initialValue: 1, rate: 0.1),
            Ability.intellect: ProgressionValue(initialValue: 0, rate: 0),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 70, rate: 38.4)
        
        let mitigationValue = ProgressionValue(initialValue: 4, rate: 1.8)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: nil, resistanceValue: nil, mitigationValue: mitigationValue)
    }
}
