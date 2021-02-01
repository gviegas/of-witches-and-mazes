//
//  ReinforcedCrate.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The ReinforcedCrate entity, an inanimate object.
///
class ReinforcedCrate: InanimateObject, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ReinforcedCrateAnimationSet.animationKeys
            .union(FlightlessMenace.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return ReinforcedCrateAnimationSet.textureNames
            .union(["Reinforced_Crate"])
            .union(FlightlessMenace.textureNames)
    }
    
    /// Creates a new instance with the given values.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - inhabited: The flag stating whether destroying the object will cause a monster to spawn.
    ///     The default value is `false`.
    ///
    init(levelOfExperience: Int, inhabited: Bool = false) {
        let data = ReinforcedCrateData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let spriteComponent = component(ofType: SpriteComponent.self)!
        let texture = TextureSource.createTexture(imageNamed: "Reinforced_Crate")
        spriteComponent.texture = texture
        
        // StateComponent
        let deathState = InanimateObjectDeathState(entity: self)
        deathState.dyingDuration = 0.075 * 6.0 + 0.05
        deathState.sfx = SoundFXSet.FX.breaking
        if inhabited {
            deathState.spawn = {
                Content(type: .enemy, isDynamic: true, isObstacle: false,
                        entity: FlightlessMenace(levelOfExperience: levelOfExperience))
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
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .typical, level: levelOfExperience)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInteractWith(entity: Entity) {
        entity.component(ofType: LiftComponent.self)?.lift(otherEntity: self)
    }
}

/// The `InanimateObjectdData` of the `ReinforcedCrate` entity.
///
fileprivate class ReinforcedCrateData: InanimateObjectData {
    
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
        name = "Reinforced Crate"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .destructible
        progressionValues = ReinforcedCrateProgressionValues.instance
        animationSet = ReinforcedCrateAnimationSet()
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `ReinforcedCrate` entity.
///
fileprivate class ReinforcedCrateProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = ReinforcedCrateProgressionValues()
    
    private init() {
        let healthPointsValue = ProgressionValue(initialValue: 17, rate: 8.0)
        
        super.init(abilityValues: [:], healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: nil, resistanceValue: nil, mitigationValue: nil)
    }
}
