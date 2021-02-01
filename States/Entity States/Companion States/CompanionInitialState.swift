//
//  CompanionInitialState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the initial state of a `Companion`.
///
class CompanionInitialState: EntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to CompanionInitialState must have a NodeComponent")
        }
        return component
    }
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The time it takes to finish the spawn process.
    ///
    private var spawnDuration: TimeInterval = 0.3
    
    override func didEnter(from previousState: GKState?) {
        elapsedTime = 0
        entity.component(ofType: VoiceComponent.self)?.voice.play(at: nodeComponent.node.position, sceneKind: .level)
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is CompanionStandardState.Type || stateClass is CompanionDeathState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if elapsedTime >= spawnDuration {
            stateMachine?.enter(CompanionStandardState.self)
        }
    }
}
