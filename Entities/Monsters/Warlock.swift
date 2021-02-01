//
//  Warlock.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Warlock entity, a monster.
///
class Warlock: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return WarlockAnimationSet.animationKeys.union(WarlockBlastAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return WarlockAnimationSet.textureNames
            .union(WarlockBlastAnimation.textureNames)
            .union([PortraitSet.warlock.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = WarlockData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 2.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterBlastState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // BlastComponent
        let damage = Damage(scale: 2.0, ratio: 0.25, level: levelOfExperience,
                            modifiers: [.intellect: 0.7], type: .magical, sfx: nil)
        let tickDamage = Damage(scale: 1.0, ratio: 0.1, level: levelOfExperience,
                                modifiers: [.intellect: 0.3], type: .magical, sfx: nil)
        let dot = DamageOverTimeCondition(tickTime: 1.0, tickDamage: tickDamage,
                                          isExclusive: false, isResettable: true,
                                          duration: 45.1, source: self, color: nil, sfx: nil)
        let animation = WarlockBlastAnimation().animation
        let blast = Blast(medium: .spell, initialSize: CGSize(width: 32.0, height: 32.0),
                          finalSize: CGSize(width: 32.0, height: 32.0), range: 630.0,
                          delay: 0.45, duration: 0.1, conclusion: 0.45,
                          damage: damage, conditions: [dot],
                          animation: animation, sfx: SoundFXSet.FX.spell)
        addComponent(BlastComponent(interaction: .monsterEffect, blast: blast))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Warlock` entity.
///
fileprivate class WarlockData: MonsterData {
    
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
        name = "Warlock"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = WarlockProgressionValues.instance
        animationSet = WarlockAnimationSet()
        portrait = PortraitSet.warlock
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.evilBeing, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Warlock` entity.
///
fileprivate class WarlockProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = WarlockProgressionValues()
    
    private init() {
        let abilityValues = [Ability.strength: ProgressionValue(initialValue: 3, rate: 0.3),
                             Ability.agility: ProgressionValue(initialValue: 3, rate: 0.3),
                             Ability.intellect: ProgressionValue(initialValue: 13, rate: 1.2),
                             Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 14, rate: 5.95)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 15, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animation for the `Warlock`'s blast.
///
fileprivate struct WarlockBlastAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Purple_Flames_", first: 1, last: 10)
        return Set<String>(standard)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        animation = (nil, standard, nil)
    }
    
    private class Standard: TextureAnimation {
        static let key = "WarlockBlastAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Purple_Flames_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
}
