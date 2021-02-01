//
//  Crate.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Crate entity, an inanimate object.
///
class Crate: InanimateObject, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return CrateAnimationSet.animationKeys
            .union(Feral.animationKeys)
            .union(Rat.animationKeys)
            .union(PlagueRat.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return CrateAnimationSet.textureNames
            .union(["Crate"])
            .union(Feral.textureNames)
            .union(Rat.textureNames)
            .union(PlagueRat.textureNames)
    }

    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - inhabited: The flag stating whether destroying the object will cause a monster to spawn.
    ///     The default value is `false`.
    ///
    init(levelOfExperience: Int, inhabited: Bool = false) {
        let data = CrateData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let spriteComponent = component(ofType: SpriteComponent.self)!
        let texture = TextureSource.createTexture(imageNamed: "Crate")
        spriteComponent.texture = texture
        
        // StateComponent
        let deathState = InanimateObjectDeathState(entity: self)
        deathState.dyingDuration = 0.075 * 6.0 + 0.05
        deathState.sfx = SoundFXSet.FX.breaking
        if inhabited {
            deathState.spawn = {
                let content: Content
                switch Double.random(in: 0...1.0) {
                case 0..<0.4:
                    content = Content(type: .enemy, isDynamic: true, isObstacle: false,
                                      entity: Feral(levelOfExperience: levelOfExperience))
                case 0.4..<0.8:
                    content = Content(type: .enemy, isDynamic: true, isObstacle: false,
                                      entity: Rat(levelOfExperience: levelOfExperience))
                default:
                    content = Content(type: .enemy, isDynamic: true, isObstacle: false,
                                      entity: PlagueRat(levelOfExperience: levelOfExperience))
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

/// The `InanimateObjectdData` of the `Crate` entity.
///
fileprivate class CrateData: InanimateObjectData {
    
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
        name = "Crate"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .destructible
        progressionValues = CrateProgressionValues.instance
        animationSet = CrateAnimationSet()
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Crate` entity.
///
fileprivate class CrateProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = CrateProgressionValues()
    
    private init() {
        let healthPointsValue = ProgressionValue(initialValue: 1, rate: 0)
        
        super.init(abilityValues: [:], healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: nil, resistanceValue: nil, mitigationValue: nil)
    }
}
