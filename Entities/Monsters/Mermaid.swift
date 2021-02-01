//
//  Mermaid.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Mermaid entity, a monster.
///
class Mermaid: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return MermaidAnimationSet.animationKeys.union(MermaidRangedAttackAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return MermaidAnimationSet.textureNames
            .union(MermaidRangedAttackAnimation.textureNames)
            .union([PortraitSet.mermaid.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = MermaidData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterRangedAttackState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // MissileComponent
        let rangedDamage = Damage(scale: 1.1, ratio: 0.2, level: levelOfExperience,
                                  modifiers: [.intellect: 0.4, .faith: 0.2],
                                  type: .magical, sfx: SoundFXSet.FX.genericHit)
        let rangedAnimation = MermaidRangedAttackAnimation().animation
        let rangedAttack = Missile(medium: .spell, range: 245.0, speed: 192.0,
                                   size: CGSize(width: 24.0, height: 24.0),
                                   delay: 0.45, conclusion: 1.75, dissipateOnHit: true,
                                   damage: rangedDamage, conditions: nil,
                                   animation: rangedAnimation,
                                   sfx: SoundFXSet.FX.liquid)
        addComponent(MissileComponent(interaction: Interaction.monsterEffectOnObstacle, missile: rangedAttack))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Mermaid` entity.
///
fileprivate class MermaidData: MonsterData {
    
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
        name = "Mermaid"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = MermaidProgressionValues.instance
        animationSet = MermaidAnimationSet()
        portrait = PortraitSet.mermaid
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.nixe, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Mermaid` entity.
///
fileprivate class MermaidProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = MermaidProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 2, rate: 0.35),
            Ability.agility: ProgressionValue(initialValue: 8, rate: 0.9),
            Ability.intellect: ProgressionValue(initialValue: 6, rate: 0.65),
            Ability.faith: ProgressionValue(initialValue: 5, rate: 0.45)]

        let healthPointsValue = ProgressionValue(initialValue: 11, rate: 5.45)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 20, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Mermaid`'s ranged attack.
///
fileprivate struct MermaidRangedAttackAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Watery_Projectile_Beginning_", first: 1, last: 8)
        let standard = ImageArray.createFrom(baseName: "Watery_Projectile_", first: 1, last: 8)
        let end = ImageArray.createFrom(baseName: "Watery_Projectile_End_", first: 1, last: 8)
        return Set<String>(beginning + standard + end)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let beginning = AnimationSource.getAnimation(forKey: Beginning.key) ?? Beginning()
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (beginning, standard, end)
    }

    private class Beginning: TextureAnimation {
        static let key = "MermaidRangedAttackAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Watery_Projectile_Beginning_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "MermaidRangedAttackAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Watery_Projectile_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }

    private class End: TextureAnimation {
        static let key = "MermaidRangedAttackAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Watery_Projectile_End_", first: 1, last: 8)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
