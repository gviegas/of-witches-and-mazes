//
//  MonsterRangedAttackState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when using a ranged attack.
///
class MonsterRangedAttackState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterRangedAttackState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterRangedAttackState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterRangedAttackState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterRangedAttackState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterRangedAttackState must have a TargetComponent")
        }
        return component
    }
    
    private var missileComponent: MissileComponent {
        guard let component = entity.component(ofType: MissileComponent.self) else {
            fatalError("An entity assigned to MonsterRangedAttackState must have a MissileComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The missile being used.
    ///
    private var missile: Missile?
    
    /// A flag indicating if the ranged attack was used.
    ///
    private var used: Bool = false
    
    /// The target point.
    ///
    private var target = CGPoint.zero
    
    /// The closure that replaces the usual `propelMissile(towards:)` call.
    ///
    /// If this property is set, the state will not call the `MissileComponent`'s `propelMissile(towards:)`
    /// method when it is about to fire the missile - this closure will be called instead. `Monster` entities
    /// that must propel missiles in unusual ways can use this property to do so.
    ///
    var onExecution: ((_ target: CGPoint) -> Void)?
    
    override func didEnter(from previousState: GKState?) {
        if let missile = missileComponent.missile, let target = targetComponent.target {
            self.missile = missile
            elapsedTime = 0
            used = false
            self.target = target

            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
            
            movementComponent.movement = CGVector.zero

            // Choose the animation based on the damage medium
            switch missile.medium {
            case .ranged:
                spriteComponent.animate(name: .aim)
            case .spell:
                spriteComponent.animate(name: .cast)
            default:
                spriteComponent.animate(name: .rangedAttack)
            }
        } else {
            stateMachine?.enter(MonsterStandardState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        
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
        if used {
            if elapsedTime >= (missile!.delay + missile!.conclusion) {
                stateMachine?.enter(MonsterStandardState.self)
            }
        } else if elapsedTime >= missile!.delay {
            switch missile!.medium {
            case .ranged:
                spriteComponent.animate(name: .shoot)
            case .spell:
                spriteComponent.animate(name: .castEnd)
            default:
                break
            }
            if let onExecution = onExecution {
                onExecution(target)
            } else {
                missileComponent.propelMissile(towards: target)
            }
            used = true
        }
        elapsedTime += seconds
    }
}
