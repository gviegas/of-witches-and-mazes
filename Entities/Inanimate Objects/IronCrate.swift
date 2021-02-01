//
//  IronCrate.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Iron Crate entity, an inanimate object.
///
class IronCrate: InanimateObject, InteractionDelegate, CombatResponder, TextureUser {
    
    static var textureNames: Set<String> {
        return CrateAnimationSet.textureNames.union(["Iron_Crate"])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = IronCrateData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Iron_Crate")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // Set the HealthComponent
        component(ofType: HealthComponent.self)!.isImmortal = true
        
        // StateComponent
        addComponent(StateComponent(initialState: InanimateObjectInitialState.self, states: [
            (InanimateObjectInitialState(entity: self), nil),
            (InanimateObjectStandardState(entity: self), .standard),
            (InanimateObjectLiftedState(entity: self), .lifted),
            (InanimateObjectHurledState(entity: self), .hurled)]))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 20.0, text: "Carry", delegate: self))
        
        // LiftableComponent
        let hurlDamage = Damage(scale: 1.0, ratio: 0.25, level: levelOfExperience, modifiers: [:],
                                type: .physical, sfx: nil)
        addComponent(LiftableComponent(hurlDamage: hurlDamage))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInteractWith(entity: Entity) {
        entity.component(ofType: LiftComponent.self)?.lift(otherEntity: self)
    }
    
    func didReceiveHostileAction(from source: Entity?, outcome: CombatOutcome) {
        if let position = component(ofType: NodeComponent.self)?.node.position {
            SoundFXSet.FX.steel.play(at: position, sceneKind: .level)
        }
    }
    
    func didReceiveFriendlyAction(from source: Entity?, outcome: CombatOutcome) {
    
    }
}

/// The `InanimateObjectdData` of the `IronCrate` entity.
///
fileprivate class IronCrateData: InanimateObjectData {
    
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
        name = "Iron Crate"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .destructible
        progressionValues = IronCrateProgressionValues.instance
        animationSet = nil
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `IronCrate` entity.
///
fileprivate class IronCrateProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = IronCrateProgressionValues()
    
    private init() {
        let healthPointsValue = ProgressionValue(initialValue: 1, rate: 0)
        let mitigationValue = ProgressionValue(initialValue: Int.max, rate: 0)
        
        super.init(abilityValues: [:], healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: nil, resistanceValue: nil, mitigationValue: mitigationValue)
    }
}
