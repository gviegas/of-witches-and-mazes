//
//  Hound.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/23/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Hound entity, a companion.
///
class Hound: Companion, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return HoundAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return HoundAnimationSet.textureNames.union([PortraitSet.hound.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = HoundData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // AttackComponent
        let referenceShape = data.physicsShape
        let meleeDamage = Damage(scale: 1.15, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.4, .agility: 0.1],
                                 type: .physical, sfx: SoundFXSet.FX.attack)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 32.0, broadness: 32.0, delay: 0.4, duration: 0.1, conclusion: 0.65,
                            conditions: nil, sfx: SoundFXSet.FX.hit)
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

/// The `CompanionData` defining the data associated with the `Hound` entity.
///
fileprivate class HoundData: CompanionData {
    
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
        name = "Hound"
        progressionValues = HoundProgressionValues.instance
        animationSet = HoundAnimationSet()
        portrait = PortraitSet.hound
        voice = (SoundFXSet.Voice.hound, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Hound` entity.
///
fileprivate class HoundProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = HoundProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 8, rate: 0.8),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.3),
            Ability.intellect: ProgressionValue(initialValue: 1, rate: 0.05),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 17, rate: 8.5)
        
        let defenseValue = ProgressionValue(initialValue: 15, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}
