//
//  SpikeTrapStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the standard state of a `SpikeTrap`.
///
class SpikeTrapStandardState: EntityState {
    
    /// An enum defining the available states for the spike trap.
    ///
    private enum State {
        case waiting, triggered, finishing
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to SpikeTrapStandardState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to SpikeTrapStandardState must have a PhysicsComponent")
        }
        return component
    }
    
    private var blastComponent: BlastComponent {
        guard let component = entity.component(ofType: BlastComponent.self) else {
            fatalError("An entity assigned to SpikeTrapStandardState must have a BlastComponent")
        }
        return component
    }
    
    /// The elapsed time since the last state change.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The current state.
    ///
    private var state: State = .waiting {
        didSet {
            elapsedTime = 0
        }
    }
    
    /// The interval between trap activations.
    ///
    var triggerDelay: TimeInterval = 1.0
    
    override func didEnter(from previousState: GKState?) {
        state = .waiting
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SpikeTrapDisarmedState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let blast = blastComponent.blast else { return }
        
        elapsedTime += seconds
        
        switch state {
        case .waiting:
            if elapsedTime >= triggerDelay {
                state = .triggered
                blastComponent.causeBlast(at: physicsComponent.position)
                spriteComponent.animate(name: .trigger)
            }
        case .triggered:
            if elapsedTime >= (blast.delay + blast.duration) {
                state = .finishing
                spriteComponent.animate(name: .triggerEnd)
            }
        case .finishing:
            if elapsedTime >= blast.conclusion {
                state = .waiting
            }
        }
    }
}
