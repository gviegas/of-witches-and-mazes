//
//  Barrel.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/15/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Barrel entity, an inanimate object.
///
class Barrel: InanimateObject, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return BarrelAnimationSet.animationKeys
            .union(Feral.animationKeys)
            .union(DeathCap.animationKeys)
            .union(DestroyingAngel.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return BarrelAnimationSet.textureNames
            .union(["Barrel"])
            .union(Feral.textureNames)
            .union(DeathCap.textureNames)
            .union(DestroyingAngel.textureNames)
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - inhabited: The flag stating whether destroying the object will cause a monster to spawn.
    ///     The default value is `false`.
    ///
    init(levelOfExperience: Int, inhabited: Bool = false) {
        let data = BarrelData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let spriteComponent = component(ofType: SpriteComponent.self)!
        let texture = TextureSource.createTexture(imageNamed: "Barrel")
        spriteComponent.texture = texture
        
        // StateComponent
        let deathState = InanimateObjectDeathState(entity: self)
        deathState.dyingDuration = 0.075 * 6.0 + 0.05
        deathState.sfx = SoundFXSet.FX.breaking
        if inhabited {
            deathState.spawn = {
                let content: Content
                switch Double.random(in: 0...1.0) {
                case 0..<0.5:
                    content = Content(type: .enemy, isDynamic: true, isObstacle: false,
                                      entity: Feral(levelOfExperience: levelOfExperience))
                case 0.5..<0.8:
                    content = Content(type: .enemy, isDynamic: true, isObstacle: false,
                                      entity: DeathCap(levelOfExperience: levelOfExperience))
                default:
                    content = Content(type: .enemy, isDynamic: true, isObstacle: false,
                                      entity: DestroyingAngel(levelOfExperience: levelOfExperience))
                }
                return content
            }
        }
        addComponent(StateComponent(initialState: InanimateObjectInitialState.self, states: [
            (InanimateObjectInitialState(entity: self), nil),
            (InanimateObjectStandardState(entity: self), .standard),
            (InanimateObjectLiftedState(entity: self), .lifted),
            (InanimateObjectHurledState(entity: self), .hurled),
            (deathState, .death)]))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 20.0, text: "Carry", delegate: self))
        
        // LiftableComponent
        let hurlDamage = Damage(scale: 1.0, ratio: 0.25, level: levelOfExperience, modifiers: [:],
                                type: .physical, sfx: SoundFXSet.FX.cracking)
        addComponent(LiftableComponent(hurlDamage: hurlDamage))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .inferior,
                                                                 level: levelOfExperience)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInteractWith(entity: Entity) {
        entity.component(ofType: LiftComponent.self)?.lift(otherEntity: self)
    }
}

/// The `InanimateObjectdData` of the `Barrel` entity.
///
fileprivate class BarrelData: InanimateObjectData {
    
    let name: String
    let size: CGSize
    let physicsShape: PhysicsShape
    let interaction: Interaction
    let progressionValues: EntityProgressionValues?
    let animationSet: DirectionalAnimationSet?
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Barrel"
        size = CGSize(width: 32.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -20.0))
        interaction = .destructible
        progressionValues = BarrelProgressionValues.instance
        animationSet = BarrelAnimationSet()
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Barrel` entity.
///
fileprivate class BarrelProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = BarrelProgressionValues()
    
    private init() {
        let healthPointsValue = ProgressionValue(initialValue: 1, rate: 0)
        
        super.init(abilityValues: [:], healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: nil, resistanceValue: nil, mitigationValue: nil)
    }
}
