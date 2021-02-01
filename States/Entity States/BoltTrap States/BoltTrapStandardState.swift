//
//  BoltTrapStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the standard state of a `BoltTrap`.
///
class BoltTrapStandardState: EntityState {
    
    /// An enum defining the available states for the bolt trap.
    ///
    private enum State {
        case waiting, triggered, finishing
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to BoltTrapStandardState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to BoltTrapStandardState must have a PhysicsComponent")
        }
        return component
    }
    
    private var missileComponent: MissileComponent {
        guard let component = entity.component(ofType: MissileComponent.self) else {
            fatalError("An entity assigned to BoltTrapStandardState must have a MissileComponent")
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
    
    override func didEnter(from previousState: GKState?) {
        state = .waiting
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is BoltTrapDisarmedState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let missile = missileComponent.missile else { return }
        
        elapsedTime += seconds
        
        switch state {
        case .waiting:
            if elapsedTime >= missile.delay {
                state = .triggered
                trigger()
                SoundFXSet.FX.trap.play(at: physicsComponent.position, sceneKind: .level)
            }
        case .triggered:
            if elapsedTime >= 0.1 {
                state = .finishing
            }
        case .finishing:
            if elapsedTime >= missile.conclusion {
                state = .waiting
            }
        }
    }
    
    /// Triggers the bolt trap.
    ///
    private func trigger() {
        let (x, y) = (physicsComponent.position.x, physicsComponent.position.y)
        let points = [CGPoint(x: x - 1, y: y), CGPoint(x: x, y: y - 1),
                      CGPoint(x: x + 1, y: y), CGPoint(x: x, y: y + 1)]
        points.forEach { missileComponent.propelMissile(towards: $0) }
    }
}
