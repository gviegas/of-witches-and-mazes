//
//  ProtagonistAttackState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/6/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Protagonist` when executing an attack.
///
class ProtagonistAttackState: ControllableEntityState {
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have a TargetComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have a SubjectComponent")
        }
        return component
    }
    
    private var attackComponent: AttackComponent {
        guard let component = entity.component(ofType: AttackComponent.self) else {
            fatalError("An entity assigned to ProtagonistAttackState must have an AttackComponent")
        }
        return component
    }
    
    override func didEnter(from previousState: GKState?) {
        subjectComponent.nullifyCurrent()
        
        // Direct the attack towards locked target or cursor location
        let target = targetComponent.target ?? InputManager.cursorLocation
        let origin = physicsComponent.position
        let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
        let direction = Direction.fromAngle(atan2(point.y, point.x))
        directionComponent.direction = direction
        
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .attack)
        attackComponent.executeAttack()
    }
    
    override func willExit(to nextState: GKState) {
        switch nextState {
        case is ProtagonistDeathState, is ProtagonistQuelledState:
            attackComponent.finishAttack()
        default:
            break
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ProtagonistStandardState.Type,
             is ProtagonistDeathState.Type,
             is ProtagonistQuelledState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if !attackComponent.isExecuting {
            stateMachine?.enter(ProtagonistStandardState.self)
        }
    }
}
