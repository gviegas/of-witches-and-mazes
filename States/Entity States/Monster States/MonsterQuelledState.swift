//
//  MonsterQuelledState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Monster` when quelled.
///
class MonsterQuelledState: EntityState {
    
    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to MonsterQuelledState must have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to MonsterQuelledState must have a SpriteComponent")
        }
        return component
    }
    
    private var perceptionComponent: PerceptionComponent {
        guard let component = entity.component(ofType: PerceptionComponent.self) else {
            fatalError("An entity assigned to MonsterQuelledState must have a PerceptionComponent")
        }
        return component
    }
    
    private var vulnerabilityComponent: VulnerabilityComponent {
        guard let component = entity.component(ofType: VulnerabilityComponent.self) else {
            fatalError("An entity assigned to MonsterQuelledState must have a VulnerabilityComponent")
        }
        return component
    }
    
    private var quellComponent: QuellComponent {
        guard let component = entity.component(ofType: QuellComponent.self) else {
            fatalError("An entity assigned to MonsterQuelledState must have a QuellComponent")
        }
        return component
    }
    
    /// The elapsed time since entering the state.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The `Quelling` instance.
    ///
    private var quelling: Quelling!
    
    override func didEnter(from previousState: GKState?) {
        quelling = quellComponent.quelling
        
        guard quelling != nil else {
            stateMachine?.enter(MonsterStandardState.self)
            return
        }
        
        elapsedTime = 0
        perceptionComponent.detach()
        if quelling.makeVulnerable { vulnerabilityComponent.increaseVulnerability() }
        movementComponent.movement = CGVector.zero
        spriteComponent.animate(name: .quell)
    }
    
    override func willExit(to nextState: GKState) {
        perceptionComponent.attach()
        if quelling.makeVulnerable { vulnerabilityComponent.decreaseVulnerability() }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is MonsterStandardState.Type,
             is MonsterDeathState.Type:
            return true
        default:
            return false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        guard let duration = quelling.duration, elapsedTime >= duration else { return }
        stateMachine?.enter(MonsterStandardState.self)
    }
    
    /// Informs the state that the entity suffered damage.
    ///
    /// If the `Quelling` instance used by the state has `breakOnDamage` defined as `true`, it
    /// will exit to the standard state. If the quelling does not break on damage, this method
    /// does nothing.
    ///
    func didSufferDamage() {
        guard quelling.breakOnDamage else { return }
        stateMachine?.enter(MonsterStandardState.self)
    }
}
