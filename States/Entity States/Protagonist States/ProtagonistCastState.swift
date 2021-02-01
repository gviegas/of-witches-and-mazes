//
//  ProtagonistCastState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the state of a `Protagonist` when casting a spell.
///
class ProtagonistCastState: ControllableEntityState {
    
    /// An enum that defines the cast states.
    ///
    private enum State {
        case beginning, standard, end
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a DirectionComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a PhysicsComponent")
        }
        return component
    }

    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a TargetComponent")
        }
        return component
    }
    
    private var subjectComponent: SubjectComponent {
        guard let component = entity.component(ofType: SubjectComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a SubjectComponent")
        }
        return component
    }
    
    private var groupComponent: GroupComponent {
        guard let component = entity.component(ofType: GroupComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a GroupComponent")
        }
        return component
    }
    
    private var castComponent: CastComponent {
        guard let component = entity.component(ofType: CastComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a CastComponent")
        }
        return component
    }
    
    private var throwingComponent: ThrowingComponent {
        guard let component = entity.component(ofType: ThrowingComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a ThrowingComponent")
        }
        return component
    }
    
    private var rayComponent: RayComponent {
        guard let component = entity.component(ofType: RayComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a RayComponent")
        }
        return component
    }
    
    private var missileComponent: MissileComponent {
        guard let component = entity.component(ofType: MissileComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a MissileComponent")
        }
        return component
    }
    
    private var barrierComponent: BarrierComponent {
        guard let component = entity.component(ofType: BarrierComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a BarrierComponent")
        }
        return component
    }
    
    private var blastComponent: BlastComponent {
        guard let component = entity.component(ofType: BlastComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a BlastComponent")
        }
        return component
    }
    
    private var influenceComponent: InfluenceComponent {
        guard let component = entity.component(ofType: InfluenceComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have an InfluenceComponent")
        }
        return component
    }
    
    private var touchComponent: TouchComponent {
        guard let component = entity.component(ofType: TouchComponent.self) else {
            fatalError("An entity assigned to ProtagonistCastState must have a TouchComponent")
        }
        return component
    }
    
    /// The current spell being cast.
    ///
    private var spell: Spell!
    
    /// The current spell book being used.
    ///
    private weak var spellBook: ResourceItem?
    
    /// The elapsed time since the last state change.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The current cast state.
    ///
    private var state: State = .beginning {
        didSet { elapsedTime = 0 }
    }
    
    /// The target point.
    ///
    private var target = CGPoint.zero
    
    /// The target entity that was currently selected upon entering the state.
    ///
    private weak var targetEntity: Entity?
    
    override func didEnter(from previousState: GKState?) {
        // Set the spell to cast
        spell = castComponent.spell
        
        guard spell != nil else {
            stateMachine?.enter(ProtagonistStandardState.self)
            return
        }
        
        // Set the spell book to use
        spellBook = castComponent.spellBook
        
        guard spellBook == nil || spellBook!.computeTotalUses(for: entity) > 0 else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Not enough spell components")
                scene.presentNote(note)
            }
            stateMachine?.enter(ProtagonistStandardState.self)
            return
        }
        
        // Check if spell kind and effect matches and set the respective effect component when needed
        let wrongKind: Bool
        switch spell.kind {
        case .throwing:
            throwingComponent.throwing = spell.effect as? Throwing
            wrongKind = throwingComponent.throwing == nil
        case .ray:
            rayComponent.ray = spell.effect as? Ray
            wrongKind = rayComponent.ray == nil
        case .missile:
            missileComponent.missile = spell.effect as? Missile
            wrongKind = missileComponent.missile == nil
        case .barrier:
            wrongKind = !(spell.effect is Barrier)
        case .targetBlast, .localBlast:
            blastComponent.blast = spell.effect as? Blast
            wrongKind = blastComponent.blast == nil
        case .targetInfluence, .localInfluence:
            influenceComponent.influence = spell.effect as? Influence
            wrongKind = influenceComponent.influence == nil
        case .targetTouch, .localTouch:
            touchComponent.touch = spell.effect as? Touch
            wrongKind = touchComponent.touch == nil
        }
        
        guard !wrongKind else {
            stateMachine?.enter(ProtagonistStandardState.self)
            return
        }
        
        // Set target entity
        targetEntity = targetComponent.source
        
        // Validate target touch requirements
        if spell.kind == .targetTouch {
            // Target touch requires a target entity, otherwise it cannot be cast
            guard let targetEntity = targetEntity else {
                if let scene = SceneManager.levelScene {
                    let note = NoteOverlay(rect: scene.frame, text: "No target selected")
                    scene.presentNote(note)
                }
                stateMachine?.enter(ProtagonistStandardState.self)
                return
            }
            // Check if the touch can affect the current target
            let validHostile = touchComponent.touch!.isHostile && groupComponent.isHostile(towards: targetEntity)
            let validFriendly = !touchComponent.touch!.isHostile && groupComponent.isFriendly(towards: targetEntity)
            guard validHostile || validFriendly else {
                if let scene = SceneManager.levelScene {
                    let note = NoteOverlay(rect: scene.frame, text: "Invalid target")
                    scene.presentNote(note)
                }
                stateMachine?.enter(ProtagonistStandardState.self)
                return
            }
        }
        
        // Update the target, clear subject, cancel movement, play cast animation and set state to beginning
        updateTarget()
        subjectComponent.nullifyCurrent()
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .cast)
        state = .beginning
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
        switch state {
        case .beginning:
            if elapsedTime >= spell.castTime.delay {
                updateTarget()
                
                guard spellBook == nil || spellBook!.computeTotalUses(for: entity) > 0 else {
                    if let scene = SceneManager.levelScene {
                        let note = NoteOverlay(rect: scene.frame, text: "Not enough spell components")
                        scene.presentNote(note)
                    }
                    stateMachine?.enter(ProtagonistStandardState.self)
                    return
                }
                
                let couldCast: Bool
                switch spell.kind {
                case .throwing:
                    couldCast = throwingComponent.toss(at: target)
                case .ray:
                    couldCast = rayComponent.causeRay(towards: target)
                case .missile:
                    couldCast = missileComponent.propelMissile(towards: target)
                case .targetBlast:
                    couldCast = blastComponent.causeBlast(at: target)
                case .targetInfluence:
                    couldCast = influenceComponent.causeInfluence(at: target)
                case .barrier:
                    barrierComponent.barrier = (spell.effect as! Barrier)
                    couldCast = true
                case .localBlast:
                    couldCast = blastComponent.causeBlast(at: physicsComponent.position)
                case .localInfluence:
                    couldCast = influenceComponent.causeInfluence(at: physicsComponent.position)
                case .localTouch:
                    couldCast = touchComponent.causeTouch(on: entity)
                case .targetTouch:
                    guard let targetEntity = targetEntity, let touch = touchComponent.touch else {
                        couldCast = false
                        break
                    }
                    let validHostile = touch.isHostile && groupComponent.isHostile(towards: targetEntity)
                    let validFriendly = !touch.isHostile && groupComponent.isFriendly(towards: targetEntity)
                    couldCast = (validHostile || validFriendly) && touchComponent.causeTouch(on: targetEntity)
                }
                
                if couldCast {
                    let _ = spellBook?.consumeResources(from: entity)
                    state = .standard
                } else {
                    entity.component(ofType: LogComponent.self)?.writeEntry(content: "Failed", style: .emphasis)
                    spriteComponent.animate(name: .castEnd)
                    state = .end
                }
            }
            
        case .standard:
            if elapsedTime >= spell.castTime.duration {
                spriteComponent.animate(name: .castEnd)
                state = .end
            }
            
        case .end:
            if elapsedTime >= spell.castTime.conclusion {
                stateMachine?.enter(ProtagonistStandardState.self)
            }
        }
        
        elapsedTime += seconds
    }
    
    /// Updates the `target` property with either the `TargetComponent`'s or the cursor location,
    /// setting the `DirectionComponent`'s direction accordingly.
    ///
    private func updateTarget() {
        // Check if targeting applies
        switch spell.kind {
        case .throwing, .ray, .missile, .targetBlast, .targetInfluence, .targetTouch:
            // Set target
            target = targetComponent.target ?? InputManager.cursorLocation
            // Make the entity face its target
            let origin = physicsComponent.position
            let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            directionComponent.direction = Direction.fromAngle(atan2(point.y, point.x))
        default:
            break
        }
    }
}
