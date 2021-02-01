//
//  MonsterAttackState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/4/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when executing an attack.
///
class MonsterAttackState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterAttackState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterAttackState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterAttackState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterAttackState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterAttackState must have a TargetComponent")
        }
        return component
    }
    
    private var attackComponent: AttackComponent {
        guard let component = entity.component(ofType: AttackComponent.self) else {
            fatalError("An entity assigned to MonsterAttackState must have an AttackComponent")
        }
        return component
    }

    override func didEnter(from previousState: GKState?) {
        if let target = targetComponent.target {
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
        }
        
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .attack)
        attackComponent.executeAttack()
    }
    
    override func willExit(to nextState: GKState) {
        switch nextState {
        case is MonsterDeathState, is MonsterQuelledState:
            attackComponent.finishAttack()
        default:
            break
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is MonsterStandardState.Type,
             is MonsterDeathState.Type,
             is MonsterQuelledState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if !attackComponent.isExecuting {
            stateMachine?.enter(MonsterStandardState.self)
        }
    }
}
