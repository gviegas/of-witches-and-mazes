//
//  MonsterRayState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when using a ray.
///
class MonsterRayState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterRayState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterRayState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterRayState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterRayState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterRayState must have a TargetComponent")
        }
        return component
    }
    
    private var rayComponent: RayComponent {
        guard let component = entity.component(ofType: RayComponent.self) else {
            fatalError("An entity assigned to MonsterRayState must have a RayComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The ray being used.
    ///
    private var ray: Ray!
    
    /// A flag indicating if the ray was used.
    ///
    private var used = false
    
    /// A flag indicating if the final animation was played.
    ///
    private var animated = false
    
    /// The target point.
    ///
    private var target = CGPoint.zero
    
    override func didEnter(from previousState: GKState?) {
        if let ray = rayComponent.ray, let target = targetComponent.target {
            self.ray = ray
            elapsedTime = 0
            used = false
            animated = false
            self.target = target
            
            movementComponent.movement = CGVector.zero
            
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
            
            // Choose the animation based on the damage medium
            switch ray.medium {
            case .spell:
                spriteComponent.animate(name: .cast)
            default:
                spriteComponent.animate(name: .causeRay)
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
            if elapsedTime >= (ray.delay + ray.duration + ray.conclusion)  {
                stateMachine?.enter(MonsterStandardState.self)
            } else if !animated && elapsedTime >= (ray.delay + ray.duration) {
                switch ray.medium {
                case .spell:
                    spriteComponent.animate(name: .castEnd)
                default:
                    break
                }
                animated = true
            }
        } else if elapsedTime >= ray.delay {
            rayComponent.causeRay(towards: target)
            used = true
        }
        elapsedTime += seconds
    }
}
