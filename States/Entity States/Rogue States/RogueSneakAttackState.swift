//
//  RogueSneakAttackState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/29/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Rogue` when using the sneak attack skill.
///
class RogueSneakAttackState: ControllableEntityState {
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have a TargetComponent")
        }
        return component
    }
    
    private var attackComponent: AttackComponent {
        guard let component = entity.component(ofType: AttackComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have an AttackComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("An entity assigend to RogueStealthState must have a SkillComponent")
        }
        return component
    }
    
    private var stealthComponent: StealthComponent {
        guard let component = entity.component(ofType: StealthComponent.self) else {
            fatalError("An entity assigned to RogueSneakAttackState must have a StealthComponent")
        }
        return component
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let sneakAttackSkill = skillComponent.skillOfClass(SneakAttackSkill.self) as? SneakAttackSkill else {
            fatalError("RogueSneakAttackState requires an entity that has SneakAttackSkill")
        }
        
        // Direct the attack towards locked target or cursor location
        let target = targetComponent.target ?? InputManager.cursorLocation
        let origin = physicsComponent.position
        let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
        let direction = Direction.fromAngle(atan2(point.y, point.x))
        directionComponent.direction = direction
        
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .attack)
        
        // Set a new attack using the skill's damage property
        attackComponent.attack = Attack(medium: .melee, damage: sneakAttackSkill.damage,
                                        reach: 48.0, broadness: 64.0,
                                        delay: 0.15, duration: 0.1, conclusion: 0.15,
                                        conditions: nil, sfx: SoundFXSet.FX.ambush)
        attackComponent.executeAttack(unavoidable: true)
    }
    
    override func willExit(to nextState: GKState) {
        stealthComponent.exitStealthMode()
        if let skill = skillComponent.skillOfClass(StealthSkill.self) {
            skillComponent.triggerSkillWaitTime(skill as! WaitTimeSkill)
            (skill as! ActiveSkill).isActive = false
        }
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
        if !attackComponent.isExecuting {
            stateMachine?.enter(ProtagonistStandardState.self)
        }
    }
}
