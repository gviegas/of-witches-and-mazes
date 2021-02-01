//
//  DialogState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/25/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass for dialogs.
///
class DialogState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to DialogState must have a MovementComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to DialogState must have a DirectionComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to DialogState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to DialogState must have a PhysicsComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to DialogState must have a SubjectComponent")
        }
        return component
    }
    
    /// The dialog overlay.
    ///
    private var dialogOverlay: DialogOverlay?
    
    /// The option overlay that was active when entering the state, to be restored when exiting.
    ///
    private var optionOverlay: OptionOverlay?
    
    override func didEnter(from previousState: GKState?) {
        guard let scene = SceneManager.levelScene else {
            stateMachine?.enter(ProtagonistStandardState.self)
            return
        }
        
        optionOverlay = scene.optionOverlay
        scene.optionOverlay = nil
        
        movementComponent.movement = CGVector.zero
        if let position = subjectComponent.subject?.component(ofType: PhysicsComponent.self)?.position {
            let origin = physicsComponent.position
            let p = CGPoint(x: position.x - origin.x, y: position.y - origin.y)
            directionComponent.direction = .fromAngle(atan2(p.y, p.x))
        }
        spriteComponent.animate(name: .idle)
        
        let text: String
        if let dialogComponent = subjectComponent.subject?.component(ofType: DialogComponent.self) {
            text = dialogComponent.text
        } else {
            text = "Greetings."
        }
        
        dialogOverlay = DialogOverlay(text: text, rect: scene.frame) {
            [unowned self] in
            SceneManager.levelScene?.removeOverlay(self.dialogOverlay!)
            self.stateMachine?.enter(ProtagonistStandardState.self)
        }
        
        scene.addOverlay(dialogOverlay!)
    }
    
    override func willExit(to nextState: GKState) {
        if let scene = SceneManager.levelScene {
            scene.removeOverlay(dialogOverlay!)
            scene.optionOverlay = optionOverlay
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ProtagonistStandardState.Type,
             is ProtagonistDeathState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didReceiveEvent(_ event: Event) {
        // Note: Cancel and pause are bound to the same key
        if event.isMouseEvent { super.didReceiveEvent(event) }
        dialogOverlay?.didReceiveEvent(event)
    }
}
