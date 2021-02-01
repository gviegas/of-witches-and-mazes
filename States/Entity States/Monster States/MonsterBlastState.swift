//
//  MonsterBlastState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when using a blast.
///
class MonsterBlastState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterBlastState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterBlastState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterBlastState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterBlastState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterBlastState must have a TargetComponent")
        }
        return component
    }
    
    private var blastComponent: BlastComponent {
        guard let component = entity.component(ofType: BlastComponent.self) else {
            fatalError("An entity assigned to MonsterBlastState must have a BlastComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The blast being used.
    ///
    private var blast: Blast!
    
    /// The origin of the blast.
    ///
    private var blastOrigin: CGPoint = CGPoint.zero
    
    /// A flag indicating if the blast was used.
    ///
    private var used: Bool = false
    
    /// A flag indicating if the final animation was played.
    ///
    private var animated = false
    
    override func didEnter(from previousState: GKState?) {
        if let blast = blastComponent.blast, let target = targetComponent.target {
            self.blast = blast
            elapsedTime = 0
            used = false
            animated = false
            blastOrigin = target
            
            movementComponent.movement = CGVector.zero
            
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
            
            // Choose the animation based on the damage medium
            switch blast.medium {
            case .spell:
                spriteComponent.animate(name: .cast)
            default:
                spriteComponent.animate(name: .causeBlast)
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
            if elapsedTime >= (blast.delay + blast.duration + blast.conclusion)  {
                stateMachine?.enter(MonsterStandardState.self)
            } else if !animated && elapsedTime >= (blast.delay + blast.duration) {
                switch blast.medium {
                case .spell:
                    spriteComponent.animate(name: .castEnd)
                default:
                    break
                }
                animated = true
            }
        } else if elapsedTime >= blast.delay {
            blastComponent.causeBlast(at: blastOrigin)
            used = true
        }
        elapsedTime += seconds
    }
}
