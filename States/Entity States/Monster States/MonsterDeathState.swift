//
//  MonsterDeathState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/8/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when dying.
///
class MonsterDeathState: EntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to MonsterDeathState must have a NodeComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterDeathState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterDeathState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to MonsterDeathState must have a PhysicsComponent")
        }
        return component
    }
    
    private var statusBarComponent: StatusBarComponent {
        guard let component = entity.component(ofType: StatusBarComponent.self) else {
            fatalError("An entity assigned to MonsterDeathState must have a StatusBarComponent")
        }
        return component
    }
    
    private var conditionComponent: ConditionComponent {
        guard let component = entity.component(ofType: ConditionComponent.self) else {
            fatalError("An entity assigned to MonsterDeathState must have a ConditionComponent")
        }
        return component
    }
    
    private var shadowComponent: ShadowComponent? {
        return entity.component(ofType: ShadowComponent.self)
    }
    
    private var auraComponent: AuraComponent? {
        return entity.component(ofType: AuraComponent.self)
    }
    
    /// The time it takes to finish the dying process.
    ///
    private let dyingDuration: TimeInterval = 1.0
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The flag stating whether the state completed its execution.
    ///
    private var completed: Bool = false
    
    /// The `SoundFX` that plays when the entity is dying.
    ///
    private var sfx: SoundFX {
        return SoundFXSet.FX.dying
    }
    
    override func didEnter(from previousState: GKState?) {
        movementComponent.movement = CGVector.zero
        if !spriteComponent.animate(name: .death) {
            // Entity did not provide a death animation, play the default one
            spriteComponent.animate(animation: DeathAnimation.instance)
        }
        physicsComponent.remove()
        statusBarComponent.detach()
        shadowComponent?.detach(withFadeEffect: true)
        auraComponent?.detach(withFadeEffect: true)
        conditionComponent.removeAllConditions()
        sfx.play(at: nodeComponent.node.position, sceneKind: .level)
        
        if let protagonist = Game.protagonist {
            // Award experience
            EntityProgression.awardXP(to: protagonist, from: entity)
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        guard !completed, elapsedTime >= dyingDuration else { return }
        
        let _ = entity.component(ofType: LootComponent.self)?.drop()
        entity.level?.removeFromSublevel(entity: entity)
        
        completed = true
    }
}
