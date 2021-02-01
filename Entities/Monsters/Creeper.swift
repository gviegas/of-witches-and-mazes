//
//  Creeper.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Creeper entity, a monster.
///
class Creeper: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return CreeperAnimationSet.animationKeys.union(CreeperBlastAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return CreeperAnimationSet.textureNames
            .union(CreeperBlastAnimation.textureNames)
            .union([PortraitSet.creeper.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = CreeperData(levelOfExperience: levelOfExperience)
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
        let blastDamage = Damage(scale: 1.25, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.3],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let blastAnimation = CreeperBlastAnimation().animation
        let blast = Blast(medium: .ranged,
                          initialSize: CGSize(width: 16.0, height: 16.0),
                          finalSize: CGSize(width: 32.0, height: 32.0),
                          range: 175.0,
                          delay: 0.6, duration: 0.4, conclusion: 0.6,
                          damage: blastDamage, conditions: nil,
                          animation: blastAnimation, sfx: SoundFXSet.FX.grass)
        addComponent(BlastComponent(interaction: Interaction.monsterEffect, blast: blast))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Creeper` entity.
///
fileprivate class CreeperData: MonsterData {
    
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
        name = "Creeper"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .verySlow
        physicsShape = .rectangle(size: CGSize(width: 20.0, height: 20.0), center: CGPoint(x: 0, y: -22.0))
        progressionValues = CreeperProgressionValues.instance
        animationSet = CreeperAnimationSet()
        portrait = PortraitSet.creeper
        shadow = (CGSize(width: 18.0, height: 12.0), "Shadow")
        voice = nil
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Creeper` entity.
///
fileprivate class CreeperProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = CreeperProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 6, rate: 0.65),
            Ability.agility: ProgressionValue(initialValue: 1, rate: 0.2),
            Ability.intellect: ProgressionValue(initialValue: 0, rate: 0),
            Ability.faith: ProgressionValue(initialValue: 0, rate: 0)]
        
        let healthPointsValue = ProgressionValue(initialValue: 15, rate: 7.3)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}

/// The structs defining the animations for the `Creeper`'s blast.
///
fileprivate struct CreeperBlastAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Stem_", first: 1, last: 20)
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
        static let key = "CreeperBlastAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Stem_", first: 1, last: 20)
            super.init(images: images, timePerFrame: 0.05, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        //    override func play(node: SKNode) {
        //        (node as! SKSpriteNode).anchorPoint = CGPoint(x: 0.5, y: 0)
        //        super.play(node: node)
        //    }
    }
}
