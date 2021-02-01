//
//  MonsterStayState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when staying put.
///
class MonsterStayState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterStayState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to MonsterStayState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterStayState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterStayState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to MonsterStayState must have a TargetComponent")
        }
        return component
    }

    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The time to stay.
    ///
    private var duration: TimeInterval = 1.0
    
    override func didEnter(from previousState: GKState?) {
        if let target = targetComponent.target {
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
        }
        
        elapsedTime = 0
        movementComponent.movement = CGVector.zero
        
        let animation = (spriteComponent.animationName, spriteComponent.animationDirection)
        if animation.0 != .idle/*.walk*/ || animation.1 != directionComponent.direction {
            spriteComponent.animate(name: .idle/*.walk*/)
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
        elapsedTime += seconds
        if elapsedTime >= duration {
            stateMachine?.enter(MonsterStandardState.self)
        }
    }
}
