//
//  IntroUseState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the use state during the introduction.
///
class IntroUseState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to IntroUseState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to IntroUseState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to IntroUseState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to IntroUseState must have a PhysicsComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to IntroUseState must have a SubjectComponent")
        }
        return component
    }
    
    private var actionComponent: ActionComponent {
        guard let component = entity.component(ofType: ActionComponent.self) else {
            fatalError("An entity assigned to IntroUseState must have an ActionComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The action being performed.
    ///
    private var action: Action!
    
    /// A flag stating if the executing is starting.
    ///
    private var starting: Bool = false
    
    /// A flag stating if the executing is ending.
    ///
    private var ending: Bool = false
    
    override func didEnter(from previousState: GKState?) {
        if let action = actionComponent.action {
            self.action = action
            elapsedTime = 0
            starting = true
            ending = false
            subjectComponent.nullifyCurrent()
            movementComponent.movement = CGVector.zero
            if let position = actionComponent.subject?.component(ofType: PhysicsComponent.self)?.position {
                let origin = physicsComponent.position
                let p = CGPoint(x: position.x - origin.x, y: position.y - origin.y)
                directionComponent.direction = .fromAngle(atan2(p.y, p.x))
            }
            spriteComponent.animate(name: .use)
            action.sfx?.before?.play(at: nil, sceneKind: .level)
        } else {
            stateMachine?.enter(IntroStandardState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IntroPageState.Type,
             is IntroInitialState.Type,
             is IntroStandardState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if starting {
            if elapsedTime >= action.delay {
                action.sfx?.during?.play(at: nil, sceneKind: .level)
                actionComponent.delegate?.didAct(action, entity: entity)
                actionComponent.delegate = nil
                actionComponent.subject = nil
                starting = false
            }
        } else if ending {
            if elapsedTime >= (action.delay + action.duration + action.conclusion) {
                stateMachine?.enter(IntroStandardState.self)
            }
        } else if elapsedTime >= (action.delay + action.duration) {
            spriteComponent.animate(name: .useEnd)
            action.sfx?.after?.play(at: nil, sceneKind: .level)
            ending = true
        }
        elapsedTime += seconds
    }
}
