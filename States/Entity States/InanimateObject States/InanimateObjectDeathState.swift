//
//  InanimateObjectDeathState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of an `InanimateObject` when being destroyed.
///
class InanimateObjectDeathState: EntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to InanimateObjectDeathState must have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to InanimateObjectDeathState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to InanimateObjectDeathState must have a PhysicsComponent")
        }
        return component
    }
    
    /// The flag stating whether the state completed its execution.
    ///
    private var completed: Bool = false
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The time it takes to finish the dying process.
    ///
    var dyingDuration: TimeInterval = 1.0
    
    /// The `SoundFX` that plays when the entity is dying.
    ///
    var sfx: SoundFX?
    
    /// The closure to use when spawning a monster.
    ///
    var spawn: (() -> Content)?
    
    override func didEnter(from previousState: GKState?) {
        if !spriteComponent.animate(name: .death) {
            // Entity did not provide a death animation, play the default one
            spriteComponent.animate(animation: DeathAnimation.instance)
        }
        physicsComponent.remove()
        sfx?.play(at: nodeComponent.node.position, sceneKind: .level)
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
        if spawn != nil { entity.level?.addContent(spawn!(), at: physicsComponent.position) }
        entity.level?.removeFromSublevel(entity: entity)
        
        completed = true
    }
}
