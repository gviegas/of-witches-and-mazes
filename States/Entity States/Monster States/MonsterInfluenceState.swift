//
//  MonsterInfluenceState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when using an influence.
///
class MonsterInfluenceState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterInfluenceState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterInfluenceState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterInfluenceState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterInfluenceState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterInfluenceState must have a TargetComponent")
        }
        return component
    }
    
    private var influenceComponent: InfluenceComponent {
        guard let component = entity.component(ofType: InfluenceComponent.self) else {
            fatalError("An entity assigned to MonsterInfluenceState must have a InfluenceComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The Influence being used.
    ///
    private var influence: Influence?
    
    /// The origin of the Influence.
    ///
    private var influenceOrigin: CGPoint = CGPoint.zero
    
    /// A flag indicating if the Influence is finishing its effects.
    ///
    private var isFinishing: Bool = false
    
    override func didEnter(from previousState: GKState?) {
        if let influence = influenceComponent.influence, let target = targetComponent.target {
            self.influence = influence
            elapsedTime = 0
            isFinishing = false
            influenceOrigin = influence.range > 1.0 ? target : physicsComponent.position
            
            movementComponent.movement = CGVector.zero
            
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
            
            spriteComponent.animate(name: .cast)
            
            // Start the influence effect
            influenceComponent.causeInfluence(at: influenceOrigin)
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
        if isFinishing {
            if elapsedTime >= (influence!.delay + influence!.duration + influence!.conclusion)  {
                stateMachine?.enter(MonsterStandardState.self)
            }
        } else if elapsedTime >= (influence!.delay + influence!.duration) {
            spriteComponent.animate(name: .castEnd)
            isFinishing = true
        }
        elapsedTime += seconds
    }
}
