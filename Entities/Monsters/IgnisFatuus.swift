//
//  IgnisFatuus.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Ignis Fatuus entity, a monster.
///
class IgnisFatuus: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return IgnisFatuusAnimationSet.animationKeys.union(IgnisFatuusBlastAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return IgnisFatuusAnimationSet.textureNames
            .union(IgnisFatuusBlastAnimation.textureNames)
            .union([PortraitSet.ignisFatuus.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = IgnisFatuusData(levelOfExperience: levelOfExperience)
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
        let blastDamage = Damage(scale: 2.5, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.intellect: 0.65],
                                 type: .magical, sfx: SoundFXSet.FX.magicalHit)
        let blastAnimation = IgnisFatuusBlastAnimation().animation
        let blast = Blast(medium: .power, initialSize: CGSize(width: 0, height: 0),
                          finalSize: CGSize(width: 72.0, height: 72.0),
                          range: 350.0, delay: 0.3, duration: 0.3, conclusion: 0.3,
                          damage: blastDamage, conditions: nil,
                          animation: blastAnimation, sfx: SoundFXSet.FX.magicalAttack)
        addComponent(BlastComponent(interaction: Interaction.monsterEffect, blast: blast))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.poison]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `IgnisFatuus` entity.
///
fileprivate class IgnisFatuusData: MonsterData {
    
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
        name = "Ignis Fatuus"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .fast
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = IgnisFatuusProgressionValues.instance
        animationSet = IgnisFatuusAnimationSet()
        portrait = PortraitSet.ignisFatuus
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.secretBeing, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `IgnisFatuus` entity.
///
fileprivate class IgnisFatuusProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = IgnisFatuusProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.7),
            Ability.intellect: ProgressionValue(initialValue: 12, rate: 1.1),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 16, rate: 7.9)
        
        let defenseValue = ProgressionValue(initialValue: 85, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 85, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}


/// The struct defining the animations for the `IgnisFatuus`s blast.
///
fileprivate struct IgnisFatuusBlastAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Yellow_Gas_", first: 1, last: 12)
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
        static let key = "IgnisFatuusBlastAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Yellow_Gas_", first: 1, last: 12)
            super.init(images: images, timePerFrame: 0.05, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
}

