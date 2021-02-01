//
//  WizardDiscarnateState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass representing the state of af `Wizard` when `DiscarnateSkill` is active.
///
class WizardDiscarnateState: ControllableEntityState {
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to WizardDiscarnateState must have a SpriteComponent")
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
            didReleaseAllMoveButtons {
                [unowned self] in
                self.spriteComponent.animate(name: .idle)
            }
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        resumeMovement()
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ProtagonistUseState.Type,
             is ProtagonistDeathState.Type,
             is ProtagonistCastState.Type,
             is ProtagonistQuelledState.Type,
             is DialogState.Type:
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
            let subject = entity.component(ofType: SubjectComponent.self)?.subject
            switch subject {
            case is Portal, is Npc:
                subject!.component(ofType: InteractionComponent.self)?.interactWith(entity: entity)
            case .some:
                if let scene = SceneManager.levelScene {
                    let note = NoteOverlay(rect: scene.frame, text: "Cannot do that as a wraith")
                    scene.presentNote(note)
                }
            default:
                break
            }
        } else if !mapping.intersection(InputButton.itemButtons).isEmpty {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Cannot use items as a wraith")
                scene.presentNote(note)
            }
        } else if mapping.contains(.skill1) {
            didPressSkillButton(.skill1)
        } else if mapping.contains(.skill2) {
            didPressSkillButton(.skill2)
        } else if mapping.contains(.skill3) {
            didPressSkillButton(.skill3)
        } else if mapping.contains(.skill4) {
            didPressSkillButton(.skill4)
        } else if mapping.contains(.skill5) {
            didPressSkillButton(.skill5)
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
