//
//  ProtagonistLiftState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/19/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Protagonist` when lifting.
///
class ProtagonistLiftState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to ProtagonistLiftState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to ProtagonistLiftState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ProtagonistLiftState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to ProtagonistLiftState must have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to ProtagonistLiftState must have a TargetComponent")
        }
        return component
    }
    
    private var liftComponent: LiftComponent {
        guard let component = entity.component(ofType: LiftComponent.self) else {
            fatalError("An entity assigned to ProtagonistLiftState must have a LiftComponent")
        }
        return component
    }
    
    /// The speed reduction.
    ///
    private let speedReduction: CGFloat = 0.75
    
    /// The time it takes to fully lift, before it can start moving.
    ///
    private let liftDuration: TimeInterval = 0.5
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The flag stating if the subject is lifted.
    ///
    private var isLifted = false
    
    /// The `SoundFX` that plays when lifting.
    ///
    private var sfx: SoundFX {
        return SoundFXSet.FX.choosing
    }
    
    /// Handles currently pressed buttons, resuming movement if needed.
    ///
    private func resumeMovement() {
        if InputManager.isPressed(inputButton: .right) {
            didPressMoveButton(.right) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if InputManager.isPressed(inputButton: .left) {
            didPressMoveButton(.left) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if InputManager.isPressed(inputButton: .down) {
            didPressMoveButton(.down) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if InputManager.isPressed(inputButton: .up) {
            didPressMoveButton(.up) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else {
            didReleaseAllMoveButtons {
                [unowned self] in
                self.spriteComponent.animate(name: .hold)
            }
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsedTime = 0
        isLifted = false
        movementComponent.movement = CGVector.zero
        movementComponent.modifyMultiplier(by: -speedReduction)
        if let position = liftComponent.liftSubject?.component(ofType: PhysicsComponent.self)?.position {
            let origin = physicsComponent.position
            let p = CGPoint(x: position.x - origin.x, y: position.y - origin.y)
            directionComponent.direction = .fromAngle(atan2(p.y, p.x))
        }
        spriteComponent.animate(name: .lift)
        sfx.play(at: nil, sceneKind: .level)
    }
    
    override func willExit(to nextState: GKState) {
        SceneManager.levelScene?.optionOverlay = nil
        
        guard nextState is ProtagonistHurlState else {
            var offset = CGFloat(0)
            
            switch physicsComponent.physicsShape {
            case .circle(let radius, _): offset = radius
            case .rectangle(let size, _): offset = size.height / 2.0
            }
            
            switch liftComponent.liftSubject?.component(ofType: PhysicsComponent.self)?.physicsShape {
            case .none: offset += 16.0
            case .some(let shape):
                switch shape {
                case .circle(let radius, _): offset += radius
                case .rectangle(let size, _): offset += size.height / 2.0
                }
            }
            
            let position = CGPoint(x: physicsComponent.position.x, y: physicsComponent.position.y - offset)
            liftComponent.drop(at: position)
            movementComponent.modifyMultiplier(by: speedReduction)
            return
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ProtagonistHurlState.Type,
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
        if !isLifted && elapsedTime >= liftDuration {
            isLifted = true
            resumeMovement()
            if let scene = SceneManager.levelScene {
                scene.optionOverlay = OptionOverlay(rect: scene.frame, options: [(.key(.interact), "Hurl")])
            }
        }
    }
    
    override func didGetControlBack() {
        resumeMovement()
    }
    
    override func didReceiveEvent(_ event: Event) {
        super.didReceiveEvent(event)
        
        // Ignore the state input if not yet lifted
        guard isLifted else { return }
        
        switch event.type {
        case .keyDown:
            if let event = event as? KeyboardEvent {
                keyDownEvent(event)
            }
        case .keyUp:
            if let event = event as? KeyboardEvent {
                keyUpEvent(event)
            }
        default:
            break
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        guard !event.isRepeating,
            let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }
        
        if mapping.contains(.right) {
            didPressMoveButton(.right) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if mapping.contains(.left) {
            didPressMoveButton(.left) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if mapping.contains(.down) {
            didPressMoveButton(.down) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if mapping.contains(.up) {
            didPressMoveButton(.up) {
                [unowned self] in
                self.spriteComponent.animate(name: .carry)
            }
        } else if mapping.contains(.interact) {
            // Note: This must never fail
            liftComponent.hurl(at: targetComponent.target ?? InputManager.cursorLocation)
        }
    }
    
    /// Handles keyboard key up events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyUpEvent(_ event: KeyboardEvent) {
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: nil) else { return }
        
        for inputButton in mapping {
            switch inputButton {
            case .up, .down, .left, .right:
                didReleaseMoveButton(inputButton, onDirectionChange: {
                    [unowned self] in
                    self.spriteComponent.animate(name: .carry)
                    }, onStop: {
                        [unowned self] in
                        self.spriteComponent.animate(name: .hold)
                })
            default:
                break
            }
        }
    }
}
