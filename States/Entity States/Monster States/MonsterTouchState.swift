//
//  MonsterTouchState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when using an Touch.
///
class MonsterTouchState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterTouchState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterTouchState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterTouchState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterTouchState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterTouchState must have a TargetComponent")
        }
        return component
    }
    
    private var touchComponent: TouchComponent {
        guard let component = entity.component(ofType: TouchComponent.self) else {
            fatalError("An entity assigned to MonsterTouchState must have a TouchComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The Touch being used.
    ///
    private var touch: Touch?
    
    /// A flag indicating if the Touch is finishing its effects.
    ///
    private var isFinishing: Bool = false
    
    override func didEnter(from previousState: GKState?) {
        if let touch = touchComponent.touch {
            self.touch = touch
            elapsedTime = 0
            isFinishing = false
            
            let targetEntity: Entity
            if touch.range > 1.0, let _ = targetComponent.source, let target = targetComponent.target {
                // Make the entity face its target
                let origin = physicsComponent.position
                let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
                directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
                targetEntity = targetComponent.source!
            } else {
                targetEntity = entity
            }
            
            movementComponent.movement = CGVector.zero
            spriteComponent.animate(name: .cast)
            
            // Start the touch effect
            touchComponent.causeTouch(on: targetEntity, suppressNotes: true)
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
            if elapsedTime >= (touch!.delay + touch!.duration + touch!.conclusion)  {
                stateMachine?.enter(MonsterStandardState.self)
            }
        } else if elapsedTime >= (touch!.delay + touch!.duration) {
            spriteComponent.animate(name: .castEnd)
            isFinishing = true
        }
        elapsedTime += seconds
    }
}
