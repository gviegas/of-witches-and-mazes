//
//  RogueStealthState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass representing the state of a `Rogue` when the stealth skill is active.
///
class RogueStealthState: ControllableEntityState {
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to RogueStealthState must have a SpriteComponent")
        }
        return component
    }
    
    private var equipmentComponent: EquipmentComponent {
        guard let component = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("An entity assigend to RogueStealthState must have an EquipmentComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("An entity assigend to RogueStealthState must have a SkillComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to RogueStealthState must have a SubjectComponent")
        }
        return component
    }
    
    private var stealthComponent: StealthComponent {
        guard let component = entity.component(ofType: StealthComponent.self) else {
            fatalError("An entity assigend to RogueStealthState must have a StealthComponent")
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
        guard let skill = skillComponent.skillOfClass(StealthSkill.self) else {
            stateMachine?.enter(ProtagonistStandardState.self)
            return
        }
        
        stealthComponent.enterStealthMode()
        (skill as! ActiveSkill).isActive = true
        resumeMovement()
    }
    
    override func willExit(to nextState: GKState) {
        if !(nextState is RogueStealState) && !(nextState is RogueSneakAttackState) {
            stealthComponent.exitStealthMode()
            if let skill = skillComponent.skillOfClass(StealthSkill.self) {
                skillComponent.triggerSkillWaitTime(skill as! WaitTimeSkill)
                (skill as! ActiveSkill).isActive = false
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is RogueStealState.Type,
             is RogueSneakAttackState.Type,
             is RogueVolleyState.Type,
             is ProtagonistStandardState.Type,
             is ProtagonistUseState.Type,
             is ProtagonistAttackState.Type,
             is ProtagonistShotState.Type,
             is ProtagonistThrowState.Type,
             is ProtagonistLiftState.Type,
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
