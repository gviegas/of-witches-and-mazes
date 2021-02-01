//
//  CompanionStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the standard state for a `Companion`.
///
class CompanionStandardState: EntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a NodeComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a TargetComponent")
        }
        return component
    }
    
    private var perceptionComponent: PerceptionComponent {
        guard let component = entity.component(ofType: PerceptionComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a PerceptionComponent")
        }
        return component
    }
    
    private var companionComponent: CompanionComponent {
        guard let component = entity.component(ofType: CompanionComponent.self) else {
            fatalError("An entity assigned to CompanionStandardState must have a CompanionComponent")
        }
        return component
    }
    
    override func didEnter(from previousState: GKState?) {
  
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is CompanionFollowState.Type,
             is CompanionChaseState.Type,
             is CompanionLiftedState.Type,
             is CompanionDeathState.Type,
             is CompanionQuelledState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if companionComponent.isFar == true {
            // Too far away, reset position and drop target
            nodeComponent.node.position = companionComponent.position!
            physicsComponent.unpin()
            targetComponent.source = nil
            perceptionComponent.attach()
        } else if targetComponent.target != nil {
            // Chase the current target
            perceptionComponent.detach()
            stateMachine?.enter(CompanionChaseState.self)
        } else if companionComponent.isClose == false {
            // Not close enough, follow companion
            perceptionComponent.attach()
            stateMachine?.enter(CompanionFollowState.self)
        } else if movementComponent.movement != .zero {
            // Go idle
            movementComponent.movement = CGVector.zero
            spriteComponent.animate(name: .idle)
            perceptionComponent.attach()
        }
    }
}
