//
//  ExplosiveBarrel.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The ExplosiveBarrel entity, an inanimate object.
///
class ExplosiveBarrel: InanimateObject, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ExplosiveBarrelAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ExplosiveBarrelAnimationSet.textureNames.union(["Explosive_Barrel"])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = ExplosiveBarrelData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let spriteComponent = component(ofType: SpriteComponent.self)!
        let texture = TextureSource.createTexture(imageNamed: "Explosive_Barrel")
        spriteComponent.texture = texture
        
        // StateComponent
        let deathState = InanimateObjectDeathState(entity: self)
        deathState.dyingDuration = 0.075 * 10.0 + 0.05
//        deathState.sfx = SoundFXSet.SFX.breaking
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
                                type: .physical, sfx: nil)
        addComponent(LiftableComponent(hurlDamage: hurlDamage))
        
        // BlastComponent
        let blastDamage = Damage(scale: 6.0, ratio: 0.45, level: levelOfExperience, modifiers: [:],
                                 type: .physical, sfx: nil)
        let blast = Blast(medium: .none,
                          initialSize: CGSize(width: 16.0, height: 16.0),
                          finalSize: CGSize(width: 96.0, height: 96.0),
                          range: 0,
                          delay: 0, duration: 0.35, conclusion: 0,
                          damage: blastDamage, conditions: nil,
                          animation: nil, sfx: SoundFXSet.FX.explosion)
        addComponent(BlastComponent(interaction: Interaction.neutralEffect, blast: blast))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didDie(source: Entity?) {
        if let position = component(ofType: NodeComponent.self)?.node.position {
            component(ofType: PhysicsComponent.self)?.remove()
            component(ofType: BlastComponent.self)?.causeBlast(at: position)
        }
        super.didDie(source: source)
    }
    
    func didInteractWith(entity: Entity) {
        entity.component(ofType: LiftComponent.self)?.lift(otherEntity: self)
    }
}

/// The `InanimateObjectdData` of the `ExplosiveBarrel` entity.
///
fileprivate class ExplosiveBarrelData: InanimateObjectData {
    
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
        name = "Explosive Barrel"
        size = CGSize(width: 32.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -20.0))
        interaction = .destructible
        progressionValues = ExplosiveBarrelProgressionValues.instance
        animationSet = ExplosiveBarrelAnimationSet()
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `ExplosiveBarrel` entity.
///
fileprivate class ExplosiveBarrelProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = ExplosiveBarrelProgressionValues()
    
    private init() {
        let healthPointsValue = ProgressionValue(initialValue: 1, rate: 0)
        
        super.init(abilityValues: [:], healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: nil, resistanceValue: nil, mitigationValue: nil)
    }
}
