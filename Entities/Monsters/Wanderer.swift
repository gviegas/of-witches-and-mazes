//
//  Wanderer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Wanderer entity, a monster.
///
class Wanderer: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return WandererAnimationSet.animationKeys.union(WandererBlastAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return WandererAnimationSet.textureNames
            .union(WandererBlastAnimation.textureNames)
            .union([PortraitSet.wanderer.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = WandererData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterBlastState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // BlastComponent
        let blastDamage = Damage(scale: 1.5, ratio: 0.3, level: levelOfExperience,
                                 modifiers: [:], type: .natural, sfx: SoundFXSet.FX.energyHit)
        let blastAnimation = WandererBlastAnimation().animation
        let blast = Blast(medium: .power, initialSize: CGSize(width: 0, height: 0),
                          finalSize: CGSize(width: 72.0, height: 72.0),
                          range: 175.0,
                          delay: 0.5, duration: 0.3, conclusion: 0.233,
                          damage: blastDamage, conditions: nil,
                          animation: blastAnimation, sfx: SoundFXSet.FX.energy)
        addComponent(BlastComponent(interaction: Interaction.monsterEffect, blast: blast))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Wanderer` entity.
///
fileprivate class WandererData: MonsterData {
    
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
        name = "Wanderer"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = WandererProgressionValues.instance
        animationSet = WandererAnimationSet()
        portrait = PortraitSet.wanderer
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = nil
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Wanderer` entity.
///
fileprivate class WandererProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = WandererProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 2, rate: 0.3),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.7),
            Ability.intellect: ProgressionValue(initialValue: 6, rate: 0.6),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 15, rate: 7.8)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 10, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Wanderer`'s blast.
///
fileprivate struct WandererBlastAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Lightning_", first: 1, last: 10)
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
        static let key = "WandererBlastAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Lightning_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
}
