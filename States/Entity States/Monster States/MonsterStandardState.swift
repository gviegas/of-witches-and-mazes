//
//  MonsterStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/4/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the standard state for a `Monster`.
///
class MonsterStandardState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterStandardState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterStandardState must have a SpriteComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterStandardState must have a TargetComponent")
        }
        return component
    }
    
    private var perceptionComponent: PerceptionComponent {
        guard let component = entity.component(ofType: PerceptionComponent.self) else {
            fatalError("An entity assigned to MonsterStandardState must have a PerceptionComponent")
        }
        return component
    }
    
    override func didEnter(from previousState: GKState?) {
        if targetComponent.target == nil {
            perceptionComponent.attach()
            movementComponent.movement = CGVector.zero
            spriteComponent.animate(name: .idle)
        } else {
            perceptionComponent.detach()
            stateMachine?.enter(MonsterChaseState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is MonsterChaseState.Type,
             is MonsterDeathState.Type,
             is MonsterQuelledState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
}
