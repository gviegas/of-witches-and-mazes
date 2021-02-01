//
//  Undine.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Undine entity, a monster.
///
class Undine: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return UndineAnimationSet.animationKeys.union(UndineBlastAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return UndineAnimationSet.textureNames
            .union(UndineBlastAnimation.textureNames)
            .union([PortraitSet.undine.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = UndineData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.2
        
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
        let blastDamage = Damage(scale: 1.9, ratio: 0.3, level: levelOfExperience,
                                 modifiers: [.intellect: 0.4, .faith: 0.15],
                                 type: .magical, sfx: SoundFXSet.FX.hit)
        let blastAnimation = UndineBlastAnimation().animation
        let blast = Blast(medium: .spell, initialSize: CGSize(width: 32.0, height: 32.0),
                          finalSize: CGSize(width: 32.0, height: 32.0),
                          range: 420.0,
                          delay: 0.6, duration: 0.2, conclusion: 0.4,
                          damage: blastDamage, conditions: nil,
                          animation: blastAnimation, sfx: SoundFXSet.FX.explosion)
        addComponent(BlastComponent(interaction: Interaction.monsterEffect, blast: blast))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Undine` entity.
///
fileprivate class UndineData: MonsterData {
    
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
        name = "Undine"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = UndineProgressionValues.instance
        animationSet = UndineAnimationSet()
        portrait = PortraitSet.undine
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.siren, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Undine` entity.
///
fileprivate class UndineProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = UndineProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 3, rate: 0.35),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.75),
            Ability.intellect: ProgressionValue(initialValue: 10, rate: 1.0),
            Ability.faith: ProgressionValue(initialValue: 5, rate: 0.65)]
        
        let healthPointsValue = ProgressionValue(initialValue: 16, rate: 8.35)
        
        let defenseValue = ProgressionValue(initialValue: 15, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 35, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Undine`'s blast.
///
fileprivate struct UndineBlastAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Lightning_Bolt_", first: 1, last: 5)
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
        static let key = "UndineBlastAnimation.Standard"
        
        init() {
            var images = ImageArray.createFrom(baseName: "Lightning_Bolt_", first: 1, last: 5)
            images.append(contentsOf: images.reversed())
            var waitings = [Int: TimeInterval]()
            for i in (images.count / 2 + 1)...(images.count - 1) { waitings[i] = 0.05 }
            super.init(images: images, timePerFrame: 0.033, replaceable: false, flipped: false,
                       repeatForever: false, waitings: waitings)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        override func play(node: SKNode) {
            (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0.5, y: 0)
            super.play(node: node)
        }
    }
}
