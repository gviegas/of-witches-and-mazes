//
//  InanimateObject.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/10/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the data associated with an `InanimateObject` instance, used to create
/// its components.
///
protocol InanimateObjectData {
    
    /// The entity name, expected to be unique.
    ///
    var name: String { get }
    
    /// The size of the entity.
    ///
    var size: CGSize { get }
    
    /// The `PhysicsShape` of the entity.
    ///
    var physicsShape: PhysicsShape { get }
    
    /// The `Interaction` of the entity.
    ///
    var interaction: Interaction { get }
    
    /// The optional progression values of the entity.
    ///
    /// - Note: If this property is `nil`, a `HealthComponent` will not be added to the entity.
    ///
    var progressionValues: EntityProgressionValues? { get }
    
    /// The optional `DirectionalAnimationSet`.
    ///
    var animationSet: DirectionalAnimationSet? { get }
}

/// The `InanimateObject` entity.
///
class InanimateObject: Entity, HealthDelegate {
    
    /// Creates a new instance from the given data and level.
    ///
    /// - Parameters:
    ///   - data: The `InanimateObjectData` associated with the entity.
    ///   - levelOfExperience: The entity's level of experience.
    ///
    init(data: InanimateObjectData, levelOfExperience: Int) {
        super.init(name: data.name)
        
        // NodeComponent
        addComponent(NodeComponent())
        
        // CursorResponderComponent
        addComponent(CursorResponderComponent(size: data.size))
        
        // DirectionComponent
        addComponent(DirectionComponent(direction: .south))
        
        // SpriteComponent
        addComponent(SpriteComponent(size: data.size, animationSet: data.animationSet))
        
        // PhysicsComponent
        addComponent(PhysicsComponent(physicsShape: data.physicsShape, interaction: data.interaction))
        
        // DepthComponent
        addComponent(DepthComponent())
        
        // LogComponent
        addComponent(LogComponent())
        
        if let progressionValues = data.progressionValues {
            if !progressionValues.abilityValues.isEmpty {
                // AbilityComponent
                let abilities = progressionValues.abilityValues.mapValues { $0.initialValue }
                addComponent(AbilityComponent(abilities: abilities))
            }
            if let _ = progressionValues.mitigationValue {
                // MitigationComponent
                addComponent(MitigationComponent())
            }
            if let _ = progressionValues.criticalHitValues {
                // CriticalHitComponent
                addComponent(CriticalHitComponent())
            }
            if progressionValues.damageCausedValues != nil || progressionValues.damageTakenValues != nil {
                // DamageAdjustmentComponent
                addComponent(DamageAdjustmentComponent())
            }
            if let _ = progressionValues.defenseValue {
                // DefenseComponent
                addComponent(DefenseComponent())
            }
            if let _ = progressionValues.resistanceValue {
                // ResistanceComponent
                addComponent(ResistanceComponent())
            }
            
            // HealthComponent
            addComponent(HealthComponent(baseHP: progressionValues.healthPointsValue.initialValue, delegate: self))
            
            // ProgressionComponent
            addComponent(ProgressionComponent(values: progressionValues, levelOfExperience: levelOfExperience))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddToLevel(_ level: Level) {
        super.didAddToLevel(level)
        
        component(ofType: StateComponent.self)?.enterInitialState()
    }
    
    override func willRemoveFromLevel(_ level: Level) {
        super.willRemoveFromLevel(level)
        
        component(ofType: NodeComponent.self)?.node.removeFromParent()
        willRemoveFromGame()
    }
    
    func didSufferDamage(amount: Int, source: Entity?) {
        
    }
    
    func didRestoreHP(amount: Int, source: Entity?) {
        
    }
    
    func didDie(source: Entity?) {
        component(ofType: StateComponent.self)?.enter(stateClass: InanimateObjectDeathState.self)
        if Game.target == self { component(ofType: CursorResponderComponent.self)?.cursorUnselected() }
        if Game.subject === self {component(ofType: InteractionComponent.self)?.willRemoveCurrent() }
    }
}
