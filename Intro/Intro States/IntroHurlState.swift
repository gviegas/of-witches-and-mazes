//
//  IntroHurlState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the hurld state during the introduction.
///
class IntroHurlState: ControllableEntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to IntroHurlState must have a NodeComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to IntroHurlState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to IntroHurlState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to IntroHurlState must have a SpriteComponent")
        }
        return component
    }
    
    private var liftComponent: LiftComponent {
        guard let component = entity.component(ofType: LiftComponent.self) else {
            fatalError("An entity assigned to IntroHurlState must have a LiftComponent")
        }
        return component
    }
    
    /// The speed reduction.
    ///
    private let speedReduction: CGFloat = 0.75
    
    /// The time it takes to finish hurling.
    ///
    private var hurlingDuration: TimeInterval = 0.5
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The flag stating if the subject was hurled.
    ///
    private var wasHurled = false
    
    /// The `SoundFX` that plays when hurling.
    ///
    private var sfx: SoundFX {
        return SoundFXSet.FX.genericAttack
    }
    
    override func didEnter(from previousState: GKState?) {
        if let target = liftComponent.hurlTarget {
            // Make the entity face the hurling target
            let origin = nodeComponent.node.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
        }
        elapsedTime = 0
        movementComponent.movement = CGVector.zero
        movementComponent.modifyMultiplier(by: speedReduction)
        spriteComponent.animate(name: .hurl)
        sfx.play(at: nil, sceneKind: .level)
        liftComponent.liftSubject = nil
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
        elapsedTime += seconds
        guard elapsedTime >= hurlingDuration else { return }
        
        stateMachine?.enter(IntroStandardState.self)
    }
}
