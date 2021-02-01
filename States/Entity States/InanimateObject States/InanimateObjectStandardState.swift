//
//  InanimateObjectStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the standard state of an `InanimateObject`.
///
class InanimateObjectStandardState: EntityState {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to InanimateObjectStandardState must have a PhysicsComponent")
        }
        return component
    }
    
    /// The time to wait before evaluating the current contacts again.
    ///
    private let evaluationDelay: TimeInterval = 1.0
    
    /// The elapsed time since last evaluation.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The flag stating whether to swap targets on a contacted entity.
    ///
    private var shouldSwapTargets: Bool {
        return Double.random(in: 0...1.0) < 0.33
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsedTime = 0
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is InanimateObjectLiftedState.Type,
             is InanimateObjectDeathState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let _ = entity.component(ofType: HealthComponent.self) else { return }
        
        elapsedTime += seconds
        
        guard elapsedTime >= evaluationDelay else { return }
        
        elapsedTime = 0
        
        for contact in physicsComponent.contactedEntities {
            switch contact {
            case is Monster, is Companion:
                guard let targetComponent = contact.component(ofType: TargetComponent.self) else { break }
                guard let currentSource = targetComponent.source, shouldSwapTargets else { break }
                if currentSource is InanimateObject {
                    targetComponent.source = nil
                } else {
                    targetComponent.source = entity
                    if targetComponent.secondarySource == nil {
                        targetComponent.secondarySource = currentSource
                    }
                }
            default:
                break
            }
        }
    }
}
