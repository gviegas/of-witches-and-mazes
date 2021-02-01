//
//  HellHound.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Hell Hound entity, a monster.
///
class HellHound: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return HellHoundAnimationSet.animationKeys.union(HellHoundAuraAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return HellHoundAnimationSet.textureNames
            .union(HellHoundAuraAnimation.textureNames)
            .union([PortraitSet.hellHound.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = HellHoundData(levelOfExperience: levelOfExperience)
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
        let meleeDamage = Damage(scale: 3.8, ratio: 0.15, level: levelOfExperience,
                                 modifiers: [.strength: 0.65, .agility: 0.1],
                                 type: .physical, sfx: SoundFXSet.FX.attack)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 40.0, broadness: 40.0, delay: 0.4, duration: 0.1, conclusion: 0.65,
                            conditions: nil, sfx: SoundFXSet.FX.hit)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
        
        // AuraComponent
        let auraDamage = Damage(scale: 1.35, ratio: 0.15, level: levelOfExperience, modifiers: [:],
                            type: .natural, sfx: nil)
        let aura = Aura(radius: 48.0, refreshTime: 1.0, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: auraDamage, conditions: nil,
                        animation: HellHoundAuraAnimation.instance, sfx: nil)
        addComponent(AuraComponent(interaction: Interaction.monsterEffect, aura: aura))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.poison, .damage(.natural)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `HellHound` entity.
///
fileprivate class HellHoundData: MonsterData {
    
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
        name = "Hell Hound"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -10.0))
        progressionValues = HellHoundProgressionValues.instance
        animationSet = HellHoundAnimationSet()
        portrait = PortraitSet.hellHound
        shadow = (CGSize(width: 30.0, height: 20.0), "Shadow")
        voice = (SoundFXSet.Voice.primalBeast, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `HellHound` entity.
///
fileprivate class HellHoundProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = HellHoundProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 15, rate: 1.5),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.3),
            Ability.intellect: ProgressionValue(initialValue: 1, rate: 0.05),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 32, rate: 15.8)
        
        let defenseValue = ProgressionValue(initialValue: 30, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}

/// The `TextureAnimation` subclass defining the animation for the `HellHound`'s aura.
///
fileprivate class HellHoundAuraAnimation: TextureAnimation, TextureUser, AnimationUser {
    private static let key = "HellHoundAuraAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    static var textureNames: Set<String> {
        let images = ImageArray.createFrom(baseName: "Immolation_", first: 1, last: 8)
        return Set<String>(images)
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? HellHoundAuraAnimation()
    }
    
    private init() {
        let images = ImageArray.createFrom(baseName: "Immolation_", first: 1, last: 8)
        super.init(images: images, timePerFrame: 0.083, replaceable: false, flipped: false, repeatForever: true)
        AnimationSource.storeAnimation(self, forKey: HellHoundAuraAnimation.key)
    }
}
