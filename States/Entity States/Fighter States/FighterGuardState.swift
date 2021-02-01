//
//  FighterGuardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/5/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllableEntityState` subclass representing the state of a `Fighter` when executing the guard skill.
///
class FighterGuardState: ControllableEntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to FighterGuardState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to FighterGuardState must have a SpriteComponent")
        }
        return component
    }
    
    private var conditionComponent: ConditionComponent {
        guard let component = entity.component(ofType: ConditionComponent.self) else {
            fatalError("An entity assigend to FighterGuardState must have a ConditionComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("An entity assigend to FighterGuardState must have a SkillComponent")
        }
        return component
    }
    
    /// The time it takes to conclude the guard.
    ///
    private let conclusion: TimeInterval = 0.25
    
    /// The elapsed time.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// A flag stating whether or not the guard is concluding.
    ///
    private var isEnding = false
    
    /// The guard's condition.
    ///
    private var condition: Condition!
    
    /// Ends the guard.
    ///
    private func end() {
        isEnding = true
        spriteComponent.animate(name: .defendEnd)
        conditionComponent.removeCondition(condition)
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let skill = skillComponent.skillOfClass(GuardSkill.self) as? ActiveSkill else {
            stateMachine?.enter(ProtagonistStandardState.self)
            return
        }
        
        elapsedTime = 0
        isEnding = false
        skill.isActive = true
        skillComponent.didChangeSkill(skill)
        condition = GuardSkill.protectionCondition
        movementComponent.movement = .zero
        spriteComponent.animate(name: .defend)
        let _ = conditionComponent.applyCondition(condition)
    }
    
    override func willExit(to nextState: GKState) {
        if !isEnding { end() }
        if let skill = skillComponent.skillOfClass(GuardSkill.self) as? ActiveSkill {
            skill.isActive = false
            skillComponent.didChangeSkill(skill)
        }
        condition = nil
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
        guard isEnding else { return }
        
        elapsedTime += seconds
        if elapsedTime >= conclusion { stateMachine?.enter(ProtagonistStandardState.self) }
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
    
    /// Handles key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        guard !event.isRepeating,
            let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }
        
        if !InputButton.actionButtons.allSatisfy({ !mapping.contains($0) }) {
            if !isEnding { end() }
        }
    }
    
    /// Handles key up events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyUpEvent(_ event: KeyboardEvent) {
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: nil) else { return }
        
        for inputButton in mapping {
            switch inputButton {
            default:
                break
            }
        }
    }
}
