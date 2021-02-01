//
//  ProtagonistShotState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Protagonist` when shooting with a bow.
///
class ProtagonistShotState: ControllableEntityState {
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a TargetComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a SubjectComponent")
        }
        return component
    }
    
    private var missileComponent: MissileComponent {
        guard let component = entity.component(ofType: MissileComponent.self) else {
            fatalError("An entity assigned to ProtagonistShotState must have a MissileComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The missile being shot.
    ///
    private var missile: Missile?
    
    /// A flag indicating if the arrow was shot.
    ///
    private var shot: Bool = false
    
    /// The target point.
    ///
    private var target = CGPoint.zero
    
    override func didEnter(from previousState: GKState?) {
        if let missile = missileComponent.missile {
            self.missile = missile
            elapsedTime = 0
            shot = false
            target = targetComponent.target ?? InputManager.cursorLocation
            
            subjectComponent.nullifyCurrent()
            
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
            
            movementComponent.movement = CGVector.zero
            spriteComponent.animate(name: .aim)
        } else {
            stateMachine?.enter(ProtagonistStandardState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        
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
        if shot {
            if elapsedTime >= (missile!.delay + missile!.conclusion) {
                stateMachine?.enter(ProtagonistStandardState.self)
            }
        } else if elapsedTime >= missile!.delay {
            missileComponent.propelMissile(towards: target)
            spriteComponent.animate(name: .shoot)
            shot = true
        }
        elapsedTime += seconds
    }
}
