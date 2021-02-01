//
//  ProtagonistDeathState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/8/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Protagonist` when dying.
///
class ProtagonistDeathState: ControllableEntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a NodeComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a PhysicsComponent")
        }
        return component
    }
    
    private var pickUpComponent: PickUpComponent {
        guard let component = entity.component(ofType: PickUpComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a PickUpComponent")
        }
        return component
    }
    
    private var statusBarComponent: StatusBarComponent {
        guard let component = entity.component(ofType: StatusBarComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a StatusBarComponent")
        }
        return component
    }
    
    private var shadowComponent: ShadowComponent {
        guard let component = entity.component(ofType: ShadowComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a ShadowComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a SubjectComponent")
        }
        return component
    }
    
    private var conditionComponent: ConditionComponent {
        guard let component = entity.component(ofType: ConditionComponent.self) else {
            fatalError("An entity assigned to ProtagonistDeathState must have a ConditionComponent")
        }
        return component
    }
    
    private var auraComponent: AuraComponent? {
        return entity.component(ofType: AuraComponent.self)
    }
    
    /// The time it takes to finish the dying process.
    ///
    private let dyingDuration: TimeInterval = 1.0
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The `SoundFX` that plays when the entity dies.
    ///
    private var sfx: SoundFX {
        return SoundFXSet.FX.dying
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsedTime = 0
        subjectComponent.nullifyCurrent()
        movementComponent.movement = CGVector.zero
        if !spriteComponent.animate(name: .death) {
            // Entity did not provide a death animation, play the default one
            spriteComponent.animate(animation: DeathAnimation.instance)
        }
        physicsComponent.remove()
        pickUpComponent.detach()
        statusBarComponent.detach()
        shadowComponent.detach(withFadeEffect: true)
        auraComponent?.detach(withFadeEffect: true)
        conditionComponent.removeAllConditions()
        sfx.play(at: nil, sceneKind: .level)
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is GameOverState.Type:
            return true
        case is WizardDiscarnateState.Type:
            return entity is Wizard
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        guard elapsedTime >= dyingDuration else { return }
        
        if let wraitComponent = entity.component(ofType: WraithComponent.self), !wraitComponent.isWraith {
            // The entity has a WraithComponent but is not a Wraith yet, turn into one
            let _ = wraitComponent.turnIntoWraith()
            physicsComponent.assign()
            pickUpComponent.attach()
            statusBarComponent.attach()
            shadowComponent.attach()
            auraComponent?.attach()
        } else {
            // Continue normally
            stateMachine?.enter(GameOverState.self)
        }
    }
}
