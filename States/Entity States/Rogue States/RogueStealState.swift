//
//  RogueStealState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass representing the state of a `Rogue` when using the
/// sleight of hand skill to steal from a target.
///
class RogueStealState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to RogueStealState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to RogueStealState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to RogueStealState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to RogueStealState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to RogueStealState must have a TargetComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("An entity assigend to RogueStealState must have a SkillComponent")
        }
        return component
    }
    
    private var stealthComponent: StealthComponent {
        guard let component = entity.component(ofType: StealthComponent.self) else {
            fatalError("An entity assigend to RogueStealState must have a StealthComponent")
        }
        return component
    }
    
    private var stealComponent: StealComponent {
        guard let component = entity.component(ofType: StealComponent.self) else {
            fatalError("An entity assigned to RogueStealState must have a StealComponent")
        }
        return component
    }
    
    /// The duration time.
    ///
    private let duration: TimeInterval = 1.0
    
    /// The conclusion time.
    ///
    private let conclusion: TimeInterval = 0.35
    
    /// The elapsed time.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The flag stating whether the state is concluding.
    ///
    private var isEnding = false
    
    override func didEnter(from previousState: GKState?) {
        guard stealComponent.examine() else {
            // Not able to steal, go to stealth state
            stateMachine?.enter(RogueStealthState.self)
            return
        }
        
        elapsedTime = 0
        isEnding = false
        movementComponent.movement = .zero
        if let target = targetComponent.target {
            let origin = physicsComponent.position
            let p = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = .fromAngle(atan2(p.y, p.x))
        }
        spriteComponent.animate(name: .use)
    }
    
    override func willExit(to nextState: GKState) {
        if !(nextState is RogueStealthState) {
            stealthComponent.exitStealthMode()
            if let skill = skillComponent.skillOfClass(StealthSkill.self) {
                skillComponent.triggerSkillWaitTime(skill as! WaitTimeSkill)
                (skill as! ActiveSkill).isActive = false
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is RogueStealthState.Type,
             is ProtagonistStandardState.Type,
             is ProtagonistDeathState.Type,
             is ProtagonistQuelledState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if isEnding {
            if elapsedTime >= duration + conclusion {
                stateMachine?.enter(RogueStealthState.self)
            }
        } else if elapsedTime >= duration {
            let _ = stealComponent.steal()
            spriteComponent.animate(name: .useEnd)
            isEnding = true
        }
    }
}
