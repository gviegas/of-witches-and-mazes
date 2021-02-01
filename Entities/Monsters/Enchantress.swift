//
//  Enchantress.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Enchantress entity, a monster.
///
class Enchantress: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return EnchantressAnimationSet.animationKeys.union(EnchantressBarrierAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return EnchantressAnimationSet.textureNames
            .union(EnchantressBarrierAnimation.textureNames)
            .union([PortraitSet.enchantress.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = EnchantressData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 2.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterInfluenceState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // BarrierComponent
        let mitigation = 9 + Int((Double(levelOfExperience) * 7.167).rounded())
        let barrier = Barrier(mitigation: mitigation,
                              isDepletable: true,
                              affectedByDispel: true,
                              size: CGSize(width: 96.0, height: 96.0),
                              duration: nil,
                              animation: EnchantressBarrierAnimation().animation,
                              sfx: nil)
        addComponent(BarrierComponent())
        component(ofType: BarrierComponent.self)!.barrier = barrier
        
        // InfluenceComponent
        addComponent(InfluenceComponent())
        component(ofType: InfluenceComponent.self)!.influence = EnchantressInfluence(entity: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Enchantress` entity.
///
fileprivate class EnchantressData: MonsterData {
    
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
        name = "Enchantress"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .normal
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
        progressionValues = EnchantressProgressionValues.instance
        animationSet = EnchantressAnimationSet()
        portrait = PortraitSet.enchantress
        shadow = (CGSize(width: 24.0, height: 16.0), "Shadow")
        voice = (SoundFXSet.Voice.singingSiren, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Enchantress` entity.
///
fileprivate class EnchantressProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = EnchantressProgressionValues()
    
    private init() {
        let abilityValues = [Ability.strength: ProgressionValue(initialValue: 2, rate: 0.3),
                             Ability.agility: ProgressionValue(initialValue: 2, rate: 0.3),
                             Ability.intellect: ProgressionValue(initialValue: 14, rate: 1.3),
                             Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 13, rate: 5.85)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        let resistanceValue = ProgressionValue(initialValue: 20, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: resistanceValue, mitigationValue: nil)
    }
}

/// The `Influence` type that defines the `Enchantress`'s influence.
///
fileprivate class EnchantressInfluence: Influence {
    
    let interaction: Interaction = .monsterEffect
    let radius: CGFloat = 420.0
    let range: CGFloat = 0
    let delay: TimeInterval = 1.3
    let duration: TimeInterval = 0.2
    let conclusion: TimeInterval = 0.5
    let animation: Animation? = nil
    let sfx: SoundFX? = SoundFXSet.FX.spellHit
    
    /// The damage to apply to affected targets.
    ///
    let damage: Damage
    
    /// The caster entity.
    ///
    weak var entity: Entity?
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("EnchantressInfluence can only be used by an entity that has a ProgressionComponent")
        }
        
        self.entity = entity

        damage = Damage(scale: 2.6, ratio: 0.25, level: progressionComponent.levelOfExperience,
                        modifiers: [.intellect: 0.75], type: .magical, sfx: SoundFXSet.FX.crushing)
    }
    
    func didInfluence(node: SKNode, source: Entity?) {
        guard let target = node.entity as? Entity else { return }
        Combat.carryOutHostileAction(using: .spell, on: target, as: source, damage: damage, conditions: nil)
    }

}

/// The struct that defines the animations for the `Enchantress`'s barrier.
///
fileprivate struct EnchantressBarrierAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        return ["White_Barrier"]
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
        static let key = "EnchantressBarrierAnimation.Standard"
        
        init() {
            super.init(images: ["White_Barrier"], replaceable: true, flipped: false, repeatForever: true,
                       fadeInDuration: 2.0, fadeOutDuration: 2.0)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: Animation {
        static let key = "EnchantressBarrierAnimation.End"
        
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
