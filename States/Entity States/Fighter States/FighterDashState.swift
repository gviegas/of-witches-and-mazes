//
//  FighterDashState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/2/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Fighter` when executing the dash skill.
///
class FighterDashState: ControllableEntityState {
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have a TargetComponent")
        }
        return component
    }
    
    private var attackComponent: AttackComponent {
        guard let component = entity.component(ofType: AttackComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have an AttackComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("An entity assigned to FighterDashState must have a SkillComponent")
        }
        return component
    }
    
    /// The bonus to apply to the entity's speed multiplier.
    ///
    private let bonusSpeedMultiplier: CGFloat = 1.0
    
    /// The time it takes for the dash to start.
    ///
    private let delay: TimeInterval = 0.15
    
    /// The time it takes to end the dash.
    ///
    private let conclusion: TimeInterval = 0.35
    
    /// The elapsed time.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The flag stating whether the dash is ending.
    ///
    private var isEnding = false
    
    /// The origin point where the dash started.
    ///
    private var origin: CGPoint = .zero
    
    /// The time limit until the dash is forced to end, even if the full distance was not covered.
    ///
    private var timeLimit: TimeInterval = 0
    
    /// The total distance to travel.
    ///
    private var distance: CGFloat = 0 {
        didSet {
            distance = min(400.0/*250.0*/, distance)
        }
    }

    /// Ends the dash.
    ///
    private func end() {
        movementComponent.movement = CGVector.zero
        movementComponent.modifyMultiplier(by: -bonusSpeedMultiplier)
        spriteComponent.animate(name: .dashEnd)
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let dashSkill = skillComponent.usableSkills.first(where: { $0 is DashSkill }) as? DashSkill
            else { fatalError("FighterDashState requires an entity that has DashSkill") }
        
        elapsedTime = 0
        isEnding = false
        origin = physicsComponent.position
        let target = targetComponent.target ?? InputManager.cursorLocation
        let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
        distance = (point.x * point.x + point.y * point.y).squareRoot()
        
        directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
        movementComponent.movement = CGVector(dx: point.x / distance, dy: point.y / distance)
        movementComponent.modifyMultiplier(by: bonusSpeedMultiplier)
        spriteComponent.animate(name: .dash)
        
        timeLimit = TimeInterval(distance / movementComponent.currentSpeed)
        let attackDuration = max(0.1, timeLimit)
        let attackCondition = DashSkill.condition
        let attack = Attack(medium: .melee, damage: dashSkill.damage,
                            reach: 70.0, broadness: 50.0,
                            delay: 0, duration: attackDuration, conclusion: 0,
                            conditions: [attackCondition], sfx: SoundFXSet.FX.blade)
        
        attackComponent.attack = attack
        attackComponent.executeAttack()
    }
    
    override func willExit(to nextState: GKState) {
        if !isEnding { end() }
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
        elapsedTime += seconds
        
        guard !isEnding else {
            if elapsedTime >= conclusion { stateMachine?.enter(ProtagonistStandardState.self) }
            return
        }
        
        let position = physicsComponent.position
        let point = CGPoint(x: position.x - origin.x, y: position.y - origin.y)
        let len = (point.x * point.x + point.y * point.y).squareRoot()
        if len >= distance || elapsedTime >= timeLimit {
            elapsedTime = 0
            isEnding = true
            end()
        }
    }
}
