//
//  ProtagonistInitialState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/9/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A `ControllabeEntityState` subclass representing the initial state of a `Protagonist`.
///
class ProtagonistInitialState: ControllableEntityState {
    
    /// The time it takes to finish the spawn process.
    ///
    private let spawnDuration: TimeInterval = 0.3
    
    /// The time spent in this state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    override func didEnter(from previousState: GKState?) {
        elapsedTime = 0
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is ProtagonistStandardState.Type || stateClass is ProtagonistDeathState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if elapsedTime >= spawnDuration {
            stateMachine?.enter(ProtagonistStandardState.self)
        }
    }
}
