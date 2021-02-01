//
//  ObeliskStandardState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the standard state of a `Obelisk`.
///
class ObeliskStandardState: EntityState {
    
    /// An enum defining the available states for the obelisk.
    ///
    private enum State {
        case waiting, triggered, finishing
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ObeliskStandardState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to ObeliskStandardState must have a PhysicsComponent")
        }
        return component
    }
    
    private var missileComponent: MissileComponent {
        guard let component = entity.component(ofType: MissileComponent.self) else {
            fatalError("An entity assigned to ObeliskStandardState must have a MissileComponent")
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
        return stateClass is ObeliskDisarmedState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let missile = missileComponent.missile else { return }
        
        elapsedTime += seconds
        
        switch state {
        case .waiting:
            if elapsedTime >= missile.delay {
                state = .triggered
                trigger()
                spriteComponent.animate(name: .trigger)
                SoundFXSet.FX.magicalAttack.play(at: physicsComponent.position, sceneKind: .level)
            }
        case .triggered:
            if elapsedTime >= 0.5 {
                state = .finishing
                spriteComponent.animate(name: .triggerEnd)
            }
        case .finishing:
            if elapsedTime >= missile.conclusion {
                state = .waiting
            }
        }
    }
    
    /// Triggers the obelisk.
    ///
    private func trigger() {
        let (x, y) = (physicsComponent.position.x, physicsComponent.position.y)
        let angle = CGFloat.random(in: 0...CGFloat.pi*2.0)
        let count = Int.random(in: 3...8)
        let ratio = CGFloat.pi * 2.0 / CGFloat(count)
        var points = [CGPoint]()
        for i in 0..<count {
            points.append(CGPoint(x: x + cos(angle + ratio * CGFloat(i)),
                                  y: y + sin(angle + ratio * CGFloat(i))))
        }
        points.forEach { missileComponent.propelMissile(towards: $0) }
    }
}
