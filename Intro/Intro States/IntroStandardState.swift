//
//  IntroStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the standard state during the introduction.
///
class IntroStandardState: ControllableEntityState {
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to IntroStandardState must have a SpriteComponent")
        }
        return component
    }
    
    private var equipmentComponent: EquipmentComponent {
        guard let component = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("An entity assigned to IntroStandardState must have an EquipmentComponent")
        }
        return component
    }
    
    /// Handles currently pressed buttons (e.g., from previous scene/state), resuming movement if needed.
    ///
    private func resumeMovement() {
        if InputManager.isPressed(inputButton: .right) {
            didPressMoveButton(.right) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else if InputManager.isPressed(inputButton: .left) {
            didPressMoveButton(.left) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else if InputManager.isPressed(inputButton: .down) {
            didPressMoveButton(.down) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else if InputManager.isPressed(inputButton: .up) {
            didPressMoveButton(.up) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else {
            spriteComponent.animate(name: .idle)
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        resumeMovement()
    }
    
    override func willExit(to nextState: GKState) {
        
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IntroPageState.Type,
             is IntroInitialState.Type,
             is IntroUseState.Type,
             is IntroAttackState.Type,
             is IntroLiftState.Type,
             is IntroHurlState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didGetControlBack() {
        resumeMovement()
    }
    
    override func canInteract() -> Bool {
        return true
    }
    
    override func didReceiveEvent(_ event: Event) {
        super.didReceiveEvent(event)
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
                self.spriteComponent.animate(name: .walk)
            }
        } else if mapping.contains(.left) {
            didPressMoveButton(.left) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else if mapping.contains(.down) {
            didPressMoveButton(.down) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else if mapping.contains(.up) {
            didPressMoveButton(.up) {
                [unowned self] in
                self.spriteComponent.animate(name: .walk)
            }
        } else if mapping.contains(.interact) {
            didPressInteractButton()
        } else if mapping.contains(.item1) {
            didPressItemButton(.item1)
        } else if mapping.contains(.item2) {
            didPressItemButton(.item2)
        } else if mapping.contains(.item3) {
            didPressItemButton(.item3)
        } else if mapping.contains(.item4) {
            didPressItemButton(.item4)
        } else if mapping.contains(.item5) {
            didPressItemButton(.item5)
        } else if mapping.contains(.item6) {
            didPressItemButton(.item6)
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
                    self.spriteComponent.animate(name: .walk)
                    }, onStop: {
                        [unowned self] in
                        self.spriteComponent.animate(name: .idle)
                })
            default:
                break
            }
        }
    }
}
