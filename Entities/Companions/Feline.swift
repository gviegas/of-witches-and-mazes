//
//  Feline.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Feline entity, a companion.
///
class Feline: Companion, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return FelineAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return FelineAnimationSet.textureNames.union([PortraitSet.feline.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = FelineData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // AttackComponent
        let referenceShape = data.physicsShape
        let meleeDamage = Damage(scale: 1.0, ratio: 0.25, level: levelOfExperience,
                                 modifiers: [.strength: 0.2, .agility: 0.3],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 32.0, delay: 0.3, duration: 0.1, conclusion: 0.45,
                            conditions: nil, sfx: SoundFXSet.FX.attack)
        addComponent(AttackComponent(interaction: Interaction.companionEffect,
                                     referenceShape: referenceShape, attack: attack))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]), radius: 20.0,
                                          text: "Carry", delegate: self))
        
        // LiftableComponent
        let hurlDamage = Damage(scale: 1.0, ratio: 0.25, level: levelOfExperience, modifiers: [:],
                                type: .physical, sfx: SoundFXSet.FX.weakHit)
        addComponent(LiftableComponent(hurlDamage: hurlDamage))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInteractWith(entity: Entity) {
        entity.component(ofType: LiftComponent.self)?.lift(otherEntity: self)
    }
}

/// The `CompanionData` defining the data associated with the `Feline` entity.
///
fileprivate class FelineData: CompanionData {
    
    let name: String
    let progressionValues: EntityProgressionValues
    let animationSet: DirectionalAnimationSet
    let portrait: Portrait
    let voice: (sound: SoundFX, volubleness: VoiceComponent.Volubleness)?
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Feline"
        progressionValues = FelineProgressionValues.instance
        animationSet = FelineAnimationSet()
        portrait = PortraitSet.feline
        voice = (SoundFXSet.Voice.cat, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Feline` entity.
///
fileprivate class FelineProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = FelineProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 3, rate: 0.4),
            Ability.agility: ProgressionValue(initialValue: 8, rate: 0.8),
            Ability.intellect: ProgressionValue(initialValue: 1, rate: 0.1),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 11, rate: 5.5)
        
        let defenseValue = ProgressionValue(initialValue: 25, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
