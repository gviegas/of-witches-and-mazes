//
//  DestroyingAngel.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Destroying Angel entity, a monster.
///
class DestroyingAngel: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return DestroyingAngelAnimationSet.animationKeys.union(DestroyingAngelAuraAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return DestroyingAngelAnimationSet.textureNames
            .union(DestroyingAngelAuraAnimation.textureNames)
            .union([PortraitSet.destroyingAngel.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = DestroyingAngelData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterStayState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // AuraComponent
        let interval: TimeInterval = 1.5
        let duration: TimeInterval = interval + 1.0 / 30.0
        let damage = Damage(scale: 0.9, ratio: 0, level: levelOfExperience, modifiers: [:], type: .natural,
                            sfx: nil)
        let dot = PoisonCondition(tickTime: interval, tickDamage: damage, isExclusive: false,
                                  isResettable: true, duration: duration, source: self)
        let weaken = WeakenCondition(damageCausedReduction: 0.9, isExclusive: true, isResettable: true,
                                     duration: duration, source: self, color: nil, sfx: nil)
        let aura = Aura(radius: 128.0, refreshTime: interval, alwaysInFront: true, affectedByDispel: true,
                        duration: nil, damage: nil, conditions: [dot, weaken],
                        animation: DestroyingAngelAuraAnimation.instance, sfx: nil)
        addComponent(AuraComponent(interaction: Interaction.monsterEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `DestroyingAngel` entity.
///
fileprivate class DestroyingAngelData: MonsterData {
    
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
        name = "Destroying Angel"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .slow
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = DestroyingAngelProgressionValues.instance
        animationSet = DestroyingAngelAnimationSet()
        portrait = PortraitSet.destroyingAngel
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.lazyBeast, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `DestroyingAngel` entity.
///
fileprivate class DestroyingAngelProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = DestroyingAngelProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 2, rate: 0.25),
            Ability.agility: ProgressionValue(initialValue: 1, rate: 0.1),
            Ability.intellect: ProgressionValue(initialValue: 3, rate: 0.35),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 14, rate: 7.1)
        
        let defenseValue = ProgressionValue(initialValue: 15, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 30, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The `TextureAnimation` sublclass defining the animation for the `DestroyingAngel`s aura.
///
fileprivate class DestroyingAngelAuraAnimation: TextureAnimation, TextureUser, AnimationUser {
    private static let key = "DestroyingAngelAuraAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    static var textureNames: Set<String> {
        let cloud = ImageArray.createFrom(baseName: "Lethargic_Cloud_", first: 1, last: 3)
        return Set<String>(cloud)
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? DestroyingAngelAuraAnimation()
    }
    
    private init() {
        let images = ImageArray.createFrom(baseName: "Lethargic_Cloud_", first: 1, last: 3)
        super.init(images: images, replaceable: false, flipped: false, repeatForever: true,
                   fadeInDuration: 3.0, fadeOutDuration: 3.0)
        AnimationSource.storeAnimation(self, forKey: DestroyingAngelAuraAnimation.key)
    }
}
