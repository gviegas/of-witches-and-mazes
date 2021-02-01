//
//  Assassin.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/31/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Assassin entity, a monster.
///
class Assassin: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return AssassinAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return AssassinAnimationSet.textureNames.union([PortraitSet.assassin.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = AssassinData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 2.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterRangedAttackState(entity: self), .attack),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // MissileComponent
        let damage = Damage(scale: 1.95, ratio: 0.35, level: levelOfExperience,
                            modifiers: [.strength: 0.2, .agility: 0.6],
                            type: .physical, sfx: SoundFXSet.FX.genericHit)
        let tickDamage = Damage(scale: 1.0, ratio: 0.1, level: levelOfExperience, modifiers: [:],
                                type: .natural, sfx: nil)
        let poison = PoisonCondition(tickTime: 2.0, tickDamage: tickDamage, isExclusive: false,
                                     isResettable: true, duration: 8.1, source: self)
        let slow = HamperCondition(slowFactor: 0.8, isExclusive: true, isResettable: true, duration: 8.1,
                                   source: self, color: nil, sfx: nil)
        let missile = Missile(medium: .ranged,
                              range: 840.0, speed: 512.0,
                              size: CGSize(width: 32.0, height: 16.0),
                              delay: 0.65, conclusion: 0.2, dissipateOnHit: true,
                              damage: damage, conditions: [poison, slow],
                              animation: (nil, ArrowItem.animation, nil),
                              sfx: SoundFXSet.FX.genericRangedAttack)
        addComponent(MissileComponent(interaction: .monsterEffectOnObstacle, missile: missile))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Assassin` entity.
///
fileprivate class AssassinData: MonsterData {
    
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
        name = "Assassin"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .fast
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = AssassinProgressionValues.instance
        animationSet = AssassinAnimationSet()
        portrait = PortraitSet.assassin
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = nil
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Assassin` entity.
///
fileprivate class AssassinProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = AssassinProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 5, rate: 0.5),
            Ability.agility: ProgressionValue(initialValue: 11, rate: 1.0),
            Ability.intellect: ProgressionValue(initialValue: 5, rate: 0.45),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.15)]
        
        let healthPointsValue = ProgressionValue(initialValue: 18, rate: 8.65)
        
        let defenseValue = ProgressionValue(initialValue: 30, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 15, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}
