//
//  RogueVolleyState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/29/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Rogue` when using the volley skill.
///
class RogueVolleyState: ControllableEntityState {
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to RogueVolleyState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to RogueVolleyState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to RogueVolleyState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to RogueVolleyState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to RogueVolleyState must have a TargetComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("An entity assigend to RogueVolleyState must have a SkillComponent")
        }
        return component
    }
    
    private var missileComponent: MissileComponent {
        guard let component = entity.component(ofType: MissileComponent.self) else {
            fatalError("An entity assigned to RogueVolleyState must have a MissileComponent")
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
    
    /// The target point for the primary shot.
    ///
    private var target = CGPoint.zero
    
    /// The target points for additional shots.
    ///
    private var otherTargets = [CGPoint]()
    
    override func didEnter(from previousState: GKState?) {
        guard let multishotSkill = skillComponent.skillOfClass(VolleySkill.self) as? VolleySkill else {
            fatalError("RogueVolleyState requires an entity that has VolleySkill")
        }
        
        elapsedTime = 0
        shot = false
        target = targetComponent.target ?? InputManager.cursorLocation
        
        // Make the entity face its target
        let origin = physicsComponent.position
        let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
        let angle = atan2(point.y, point.x)
        directionComponent.direction = Direction.fromAngle(angle)
        
        // Compute additional targets
        otherTargets = []
        let len = (point.x * point.x + point.y * point.y).squareRoot()
        otherTargets.append(CGPoint(x: origin.x + len * cos(angle + CGFloat.pi * 0.1),
                                    y: origin.y + len * sin(angle + CGFloat.pi * 0.1)))
        otherTargets.append(CGPoint(x: origin.x + len * cos(angle - CGFloat.pi * 0.1),
                                    y: origin.y + len * sin(angle - CGFloat.pi * 0.1)))
        otherTargets.append(CGPoint(x: origin.x + len * cos(angle + CGFloat.pi * 0.2),
                                    y: origin.y + len * sin(angle + CGFloat.pi * 0.2)))
        otherTargets.append(CGPoint(x: origin.x + len * cos(angle - CGFloat.pi * 0.2),
                                    y: origin.y + len * sin(angle - CGFloat.pi * 0.2)))
        
        // Create the missile to shot
        missile = Missile(medium: .ranged,
                          range: 800.0, speed: 512.0,
                          size: CGSize(width: 32.0, height: 16.0),
                          delay: 1.0, conclusion: 0.2, dissipateOnHit: true,
                          damage: multishotSkill.damage, conditions: nil,
                          animation: (nil, ArrowItem.animation, nil),
                          sfx: nil)
        
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .aim)
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
            missileComponent.missile = missile
            missileComponent.propelMissile(towards: target)
            for other in otherTargets { missileComponent.propelMissile(towards: other) }
            spriteComponent.animate(name: .shoot)
            SoundFXSet.FX.volley.play(at: physicsComponent.position, sceneKind: .level)
            shot = true
        }
        elapsedTime += seconds
    }
}
