//
//  Acolyte.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Acolyte entity, a monster.
///
class Acolyte: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return AcolyteAnimationSet.animationKeys.union(AcolyteBarrierAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return AcolyteAnimationSet.textureNames
            .union(AcolyteBarrierAnimation.textureNames)
            .union([PortraitSet.acolyte.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = AcolyteData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 1.3
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterAttackState(entity: self), .attack),
                                             (MonsterTouchState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
        
        // BarrierComponent
        let mitigation = 12 + Int((Double(levelOfExperience) * 7.167).rounded())
        let barrier = Barrier(mitigation: mitigation,
                              isDepletable: true,
                              affectedByDispel: true,
                              size: CGSize(width: 96.0, height: 96.0),
                              duration: nil,
                              animation: AcolyteBarrierAnimation().animation,
                              sfx: nil)
        addComponent(BarrierComponent())
        component(ofType: BarrierComponent.self)!.barrier = barrier
        
        // AttackComponent
        let referenceShape = data.physicsShape
        let meleeDamage = Damage(scale: 1.2, ratio: 0.2, level: levelOfExperience,
                                 modifiers: [.strength: 0.35, .faith: 0.25],
                                 type: .physical, sfx: SoundFXSet.FX.hit)
        let attack = Attack(medium: .melee, damage: meleeDamage,
                            reach: 48.0, broadness: 64.0,
                            delay: 0.2, duration: 0.1, conclusion: 0.5,
                            conditions: nil, sfx: SoundFXSet.FX.attack)
        addComponent(AttackComponent(interaction: Interaction.monsterEffect,
                                     referenceShape: referenceShape, attack: attack))
        
        // TouchComponent
        // ToDo: Heal logic - A Heal State could be entered prior to Chase State, and check if the
        // entity itself or any allies need healing.
        addComponent(TouchComponent(touch: AcolyteTouch(entity: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Acolyte` entity.
///
fileprivate class AcolyteData: MonsterData {
    
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
        name = "Acolyte"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = AcolyteProgressionValues.instance
        animationSet = AcolyteAnimationSet()
        portrait = PortraitSet.acolyte
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.femaleCleric, .normal)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Acolyte` entity.
///
fileprivate class AcolyteProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = AcolyteProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 5, rate: 0.5),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.4),
            Ability.intellect: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.faith: ProgressionValue(initialValue: 11, rate: 1.05)]
        
        let healthPointsValue = ProgressionValue(initialValue: 17, rate: 8.2)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 5, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The `Touch` type that defines the `Acolyte`'s touch.
///
fileprivate class AcolyteTouch: Touch {
    
    let isHostile: Bool = false
    let range: CGFloat = 420.0
    let delay: TimeInterval = 0.85
    let duration: TimeInterval = 0.2
    let conclusion: TimeInterval = 0.6
    let animation: Animation? = nil
    let sfx: SoundFX? = nil
    
    /// The healing applied by the effect.
    ///
    let healing: Healing
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("AcolyteTouch can only be used by an entity that has a ProgressionComponent")
        }
        
        healing = Healing(scale: 1.6, ratio: 0.1, level: progressionComponent.levelOfExperience,
                          modifiers: [.faith: 0.5], sfx: SoundFXSet.FX.liquid)
    }
    
    func didTouch(target: Entity, source: Entity?) {
        Combat.carryOutFriendlyAction(using: .spell, on: target, as: source, healing: healing, conditions: nil)
    }
}

/// The struct that defines the animations for the `Acolyte`'s barrier.
///
fileprivate struct AcolyteBarrierAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        return ["Yellow_Barrier"]
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (nil, standard, end)
    }
    
    private class Standard: TextureAnimation {
        static let key = "AcolyteBarrierAnimation.Standard"
        
        init() {
            super.init(images: ["Yellow_Barrier"], replaceable: true, flipped: false, repeatForever: true,
                       fadeInDuration: 2.0, fadeOutDuration: 2.0)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: Animation {
        static let key = "AcolyteBarrierAnimation.End"
        
        let replaceable = true
        let duration: TimeInterval?
        private let action: SKAction
        
        init() {
            let clear = SKAction.fadeAlpha(to: 0, duration: 0)
            let fadeIn = SKAction.fadeIn(withDuration: 1.0 / 6.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0 / 6.0)
            let flicker = SKAction.repeat(SKAction.sequence([fadeIn, fadeOut]), count: 3)
            action = SKAction.sequence([clear, flicker])
            duration = action.duration
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
        
        func play(node: SKNode) { node.run(action) }
    }
}
