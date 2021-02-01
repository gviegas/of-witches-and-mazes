//
//  Archpriestess.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Archpriestess entity, a monster.
///
class Archpriestess: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ArchpriestessAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ArchpriestessAnimationSet.textureNames.union([PortraitSet.archpriestess.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = ArchpriestessData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 2.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterTouchState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // SecondWindComponent
        addComponent(SecondWindComponent())
        
        // TouchComponent
        addComponent(TouchComponent(touch: ArchpriestessTouch(entity: self)))
        
        // Set ImmunityComponent
        component(ofType: ImmunityComponent.self)?.immunities = [.poison, .curse, .hampering, .quelling,
                                                                 .weakness]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Archpriestess` entity.
///
fileprivate class ArchpriestessData: MonsterData {
    
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
        name = "Archpriestess"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .fast
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = ArchpriestessProgressionValues.instance
        animationSet = ArchpriestessAnimationSet()
        portrait = PortraitSet.archpriestess
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.femaleCleric, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Archpriestess` entity.
///
fileprivate class ArchpriestessProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = ArchpriestessProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 5, rate: 0.5),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.4),
            Ability.intellect: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.faith: ProgressionValue(initialValue: 14, rate: 1.35)]
        
        let healthPointsValue = ProgressionValue(initialValue: 19, rate: 9.3)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let mitigationValue = ProgressionValue(initialValue: 3, rate: 0.9)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue,
                   mitigationValue: mitigationValue)
    }
}

/// The `Touch` type that defines the `Archpriestess`'s touch.
///
fileprivate class ArchpriestessTouch: Touch {
    
    let isHostile: Bool = true
    let range: CGFloat = 105.0
    let delay: TimeInterval = 0.85
    let duration: TimeInterval = 0.2
    let conclusion: TimeInterval = 0.6
    let animation: Animation? = nil
    let sfx: SoundFX? = nil
    
    /// The damage applied by the effect.
    ///
    let damage: Damage
    
    /// The healing applied by the effect.
    ///
    let healing: Healing
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("ArchpriestessTouch can only be used by an entity that has a ProgressionComponent")
        }
        
        damage = Damage(scale: 1.9, ratio: 0.2, level: progressionComponent.levelOfExperience,
                        modifiers: [.faith: 0.7], type: .spiritual, sfx: SoundFXSet.FX.darkHit)
        
        healing = Healing(scale: 1.9, ratio: 0.1, level: progressionComponent.levelOfExperience,
                          modifiers: [.faith: 0.7], sfx: nil)
    }
    
    func didTouch(target: Entity, source: Entity?) {
        let outcome = Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: damage,
                                                   conditions: nil)
        
        guard let source = source else { return }
        
        switch outcome {
        case .damage(let amount) where amount > 0:
            Combat.carryOutFriendlyAction(using: .spell, on: source, as: source, healing: healing, conditions: nil)
        default:
            break
        }
    }
}
