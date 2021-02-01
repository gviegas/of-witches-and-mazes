//
//  ControllableEntityState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass used by controllable entities, i.e., entities that wish to
/// respond to input events.
///
class ControllableEntityState: EntityState, Controllable {
    
    /// The `CursorResponderComponent` representing the entity being hovered over by the cursor.
    ///
    private static weak var hover: CursorResponderComponent?
    
    /// The 'CursorResponderComponent' representing the selected entity.
    ///
    private static weak var selection: CursorResponderComponent?
    
    /// Clears the current cursor selection.
    ///
    class func clearSelection() {
        selection?.cursorUnselected()
        selection = nil
    }
    
    func didReceiveEvent(_ event: Event) {
        switch event.type {
        case .mouseDown:
            if let event = event as? MouseEvent {
                mouseDownEvent(event)
            }
        case .mouseEntered:
            if let event = event as? MouseEvent {
                mouseEnteredEvent(event)
            }
        case .mouseExited:
            if let event = event as? MouseEvent {
                mouseExitedEvent(event)
            }
        case .keyDown:
            if let event = event as? KeyboardEvent {
                keyDownEvent(event)
            }
        default:
            break
        }
    }
    
    /// Handles mouse down events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseDownEvent(_ event: MouseEvent) {
        switch event.button {
        case .left:
            if let hover = ControllableEntityState.hover {
                if ControllableEntityState.selection != hover {
                    ControllableEntityState.selection?.cursorUnselected()
                    hover.cursorSelected()
                    ControllableEntityState.selection = hover
                }
            } else if let selection = ControllableEntityState.selection {
                selection.cursorUnselected()
                ControllableEntityState.selection = nil
            }
        default:
            break
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? EntityTrackingData {
            data.entity?.component(ofType: CursorResponderComponent.self)?.cursorOver()
            ControllableEntityState.hover = data.entity?.component(ofType: CursorResponderComponent.self)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? EntityTrackingData {
            data.entity?.component(ofType: CursorResponderComponent.self)?.cursorOut()
            ControllableEntityState.hover = nil
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
        
        if mapping.contains(.pause) {
            didReleaseAllMoveButtons(onStop: nil)
            let _ = SceneManager.switchToScene(ofKind: .pauseMenu)
        } else if mapping.contains(.character) {
            didReleaseAllMoveButtons(onStop: nil)
            let _ = SceneManager.switchToScene(ofKind: .characterMenu)
        } else if mapping.contains(.cycleTargets) {
            didPressCycleTargetsButton()
        } else if mapping.contains(.clearTarget) {
            didPressClearTargetButton()
        }
    }
    
    /// Cycles through nearby targets.
    ///
    final func didPressCycleTargetsButton() {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { return }
        guard let targetComponent = entity.component(ofType: TargetComponent.self) else { return }
        guard let groupComponent = entity.component(ofType: GroupComponent.self) else { return }
        guard let scene = SceneManager.levelScene else { return }
        
        let center = physicsComponent.position
        let size = scene.frame.size
        let rect = CGRect(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0,
                          width: size.width, height: size.height)
        
        var targets = [Entity: CGFloat]()
        scene.physicsWorld.enumerateBodies(in: rect) { physicsBody, flag in
            guard let target = physicsBody.node?.entity as? Entity else { return }
            guard let targetPhysicsComponent = target.component(ofType: PhysicsComponent.self) else { return }
            guard target.component(ofType: NodeComponent.self)?.node === physicsBody.node else { return }
            guard groupComponent.isHostile(towards: target) else { return }
            
            let p = CGPoint(x: targetPhysicsComponent.position.x - physicsComponent.position.x,
                            y: targetPhysicsComponent.position.y - physicsComponent.position.y)
            targets[target] = (p.x * p.x + p.y * p.y).squareRoot()
        }
        
        guard !targets.isEmpty else { return }
        
        let currentTarget = targetComponent.source
        
        guard targets.count > 1 || currentTarget != targets.first!.key else { return }
        
        ControllableEntityState.selection?.cursorUnselected()
        
        let sortedTargets = targets.sorted(by: { a, b in a.value < b.value })
        if let currentTarget = currentTarget, let i = sortedTargets.firstIndex(where: { $0.key === currentTarget }) {
            let newTarget = sortedTargets[(i+1) % sortedTargets.count].key
            targetComponent.source = newTarget
        } else {
            targetComponent.source = sortedTargets.first!.key
        }
        
        if let targetCursorResponder = targetComponent.source?.component(ofType: CursorResponderComponent.self) {
            targetCursorResponder.cursorSelected()
            ControllableEntityState.selection = targetCursorResponder
        }
    }
    
    /// Clears the target currently selected.
    ///
    final func didPressClearTargetButton() {
        if let selection = ControllableEntityState.selection {
            selection.cursorUnselected()
            ControllableEntityState.selection = nil
        }
    }
    
    /// Moves an entity in one of eight directions, axially or diagonally, in response to the
    /// pressing of a movement button.
    ///
    /// - Parameters:
    ///   - button: The pressed button.
    ///   - onDirectionChange: A closure that should be called if the entity direction changes.
    ///     The defaul value is `nil`.
    ///
    final func didPressMoveButton(_ button: InputButton, onDirectionChange: (() -> Void)? = nil) {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else {
            fatalError("The didPressMoveButton(_:onDirectionChange:) method requires a MovementComponent")
        }
        guard let directionComponent = entity.component(ofType: DirectionComponent.self) else {
            fatalError("The didPressMoveButton(_:onDirectionChange) method requires a DirectionComponent")
        }
        
        switch button {
        case .up:
            if InputManager.isPressed(inputButton: .left) {
                movementComponent.movement = CGVector(dx: -0.7071, dy: 0.7071)
            } else if InputManager.isPressed(inputButton: .right) {
                movementComponent.movement = CGVector(dx: 0.7071, dy: 0.7071)
            } else {
                movementComponent.movement = CGVector(dx: 0, dy: 1.0)
                directionComponent.direction = .north
                onDirectionChange?()
            }
        case .down:
            if InputManager.isPressed(inputButton: .left) {
                movementComponent.movement = CGVector(dx: -0.7071, dy: -0.7071)
            } else if InputManager.isPressed(inputButton: .right) {
                movementComponent.movement = CGVector(dx: 0.7071, dy: -0.7071)
            } else {
                movementComponent.movement = CGVector(dx: 0, dy: -1.0)
                directionComponent.direction = .south
                onDirectionChange?()
            }
        case .left:
            if InputManager.isPressed(inputButton: .up) {
                movementComponent.movement = CGVector(dx: -0.7071, dy: 0.7071)
            } else if InputManager.isPressed(inputButton: .down) {
                movementComponent.movement = CGVector(dx: -0.7071, dy: -0.7071)
            } else {
                movementComponent.movement = CGVector(dx: -1.0, dy: 0)
                directionComponent.direction = .west
                onDirectionChange?()
            }
        case .right:
            if InputManager.isPressed(inputButton: .up) {
                movementComponent.movement = CGVector(dx: 0.7071, dy: 0.7071)
            } else if InputManager.isPressed(inputButton: .down) {
                movementComponent.movement = CGVector(dx: 0.7071, dy: -0.7071)
            } else {
                movementComponent.movement = CGVector(dx: 1.0, dy: 0)
                directionComponent.direction = .east
                onDirectionChange?()
            }
        default:
            break
        }
    }
    
    /// Stops or moves an entity in one of eight directions, axially or diagonally, in response to
    /// the releasing of a movement button.
    ///
    /// - Parameters:
    ///   - button: The released button.
    ///   - onDirectionChange: A closure that will be called if the entity direction changes.
    ///     The default value is `nil`.
    ///   - onStop: A closure that will be called if the entity stops. The default value is `nil`.
    ///
    final func didReleaseMoveButton(_ button: InputButton, onDirectionChange: (() -> Void)? = nil,
                                    onStop: (() -> Void)? = nil) {
        
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else {
            fatalError("The didReleaseMoveButton(_:onDirectionChange:) method requires a MovementComponent")
        }
        guard let directionComponent = entity.component(ofType: DirectionComponent.self) else {
            fatalError("The didReleaseMoveButton(_:onDirectionChange) method requires a DirectionComponent")
        }
        
        switch button {
        case .up:
            if InputManager.isPressed(inputButton: .left) {
                movementComponent.movement = CGVector(dx: -1.0, dy: 0)
                directionComponent.direction = .west
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .right) {
                movementComponent.movement = CGVector(dx: 1.0, dy: 0)
                directionComponent.direction = .east
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .down) {
                movementComponent.movement = CGVector(dx: 0, dy: -1.0)
                directionComponent.direction = .south
                onDirectionChange?()
            } else {
                movementComponent.movement = CGVector.zero
                onStop?()
            }
        case .down:
            if InputManager.isPressed(inputButton: .left) {
                movementComponent.movement = CGVector(dx: -1.0, dy: 0)
                directionComponent.direction = .west
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .right) {
                movementComponent.movement = CGVector(dx: 1.0, dy: 0)
                directionComponent.direction = .east
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .up) {
                movementComponent.movement = CGVector(dx: 0, dy: 1.0)
                directionComponent.direction = .north
                onDirectionChange?()
            } else {
                movementComponent.movement = CGVector.zero
                onStop?()
            }
        case .left:
            if InputManager.isPressed(inputButton: .up) {
                movementComponent.movement = CGVector(dx: 0, dy: 1.0)
                directionComponent.direction = .north
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .down) {
                movementComponent.movement = CGVector(dx: 0, dy: -1.0)
                directionComponent.direction = .south
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .right) {
                movementComponent.movement = CGVector(dx: 1.0, dy: 0)
                directionComponent.direction = .east
                onDirectionChange?()
            } else {
                movementComponent.movement = CGVector.zero
                onStop?()
            }
        case .right:
            if InputManager.isPressed(inputButton: .up) {
                movementComponent.movement = CGVector(dx: 0, dy: 1.0)
                directionComponent.direction = .north
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .down) {
                movementComponent.movement = CGVector(dx: 0, dy: -1.0)
                directionComponent.direction = .south
                onDirectionChange?()
            } else if InputManager.isPressed(inputButton: .left) {
                movementComponent.movement = CGVector(dx: -1.0, dy: 0)
                directionComponent.direction = .west
                onDirectionChange?()
            } else {
                movementComponent.movement = CGVector.zero
                onStop?()
            }
        default:
            break
        }
    }
    
    /// Stops the entity's movement.
    ///
    /// - Parameter onStop: An optional closure to be called when the entity stops.
    ///
    final func didReleaseAllMoveButtons(onStop: (() -> Void)?) {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else {
            fatalError("The didReleaseAllMoveButtons(onStop:) method requires a MovementComponent")
        }
        
        movementComponent.movement = CGVector.zero
        onStop?()
    }
    
    /// Attempts to interact.
    ///
    final func didPressInteractButton() {
        guard canInteract() else { return }
        guard let subject = entity.component(ofType: SubjectComponent.self)?.subject else { return }
        subject.component(ofType: InteractionComponent.self)?.interactWith(entity: entity)
    }
    
    /// Attempts to use the item mapped to the given button.
    ///
    /// - Parameter button: The pressed button.
    ///
    final func didPressItemButton(_ button: InputButton) {
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self),
            let index = InputButton.itemButtons.firstIndex(of: button)
            else { return }
        
        let item = equipmentComponent.itemAt(index: index)
        let noteText: String?
        switch item {
        case .none:
            noteText = "Nothing equipped in this slot"
        case .some(let item):
            switch item {
            case let item as UsableItem:
                item.didUse(onEntity: entity)
                noteText = nil
            default:
                noteText = "This item is not usable"
            }
        }
        
        if let noteText = noteText, let scene = SceneManager.levelScene {
            let note = NoteOverlay(rect: scene.frame, text: noteText)
            scene.presentNote(note)
        }
    }
    
    /// Attempts to use the skill mapped to the given button.
    ///
    /// - Parameter button: The pressed button.
    ///
    final func didPressSkillButton(_ button: InputButton) {
        guard let skillComponent = entity.component(ofType: SkillComponent.self),
            let index = InputButton.skillButtons.firstIndex(of: button),
            skillComponent.usableSkills.count > index
            else { return }
        
        let skill = skillComponent.usableSkills[index]
        let noteText: String?
        if skill.unlocked {
            if let skill = skill as? WaitTimeSkill, skillComponent.isSkillOnWaitTime(skill).isOnWait {
                noteText = "This skill is not ready yet"
            } else {
                skill.didUse(onEntity: entity)
                noteText = nil
            }
        } else {
            noteText = "This skill is locked"
        }
        
        if let noteText = noteText, let scene = SceneManager.levelScene {
            let note = NoteOverlay(rect: scene.frame, text: noteText)
            scene.presentNote(note)
        }
    }
    
    /// Informs the state that it lost and then retrieved input controls.
    ///
    /// - Note: This method is intended to be called by `Scene` instances when they become current.
    ///
    func didGetControlBack() {
        
    }
    
    /// States whether or not the state allows interactions to take place.
    ///
    /// - Note: This method should be overriden to return `true` on subclasses where interaction
    ///   actions are valid.
    ///
    func canInteract() -> Bool {
        return false
    }
}
