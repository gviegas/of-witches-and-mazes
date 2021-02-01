//
//  InanimateObjectInitialState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the initial state of an `InanimateObject`.
///
class InanimateObjectInitialState: EntityState {
    
    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(InanimateObjectStandardState.self)
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is InanimateObjectStandardState.Type || stateClass is InanimateObjectDeathState.Type
    }
}
