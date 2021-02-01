//
//  CompanionLiftedState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/21/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Companion` when lifted.
///
class CompanionLiftedState: EntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have a PhysicsComponent")
        }
        return component
    }
    
    private var depthComponent: DepthComponent {
        guard let component = entity.component(ofType: DepthComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have a DepthComponent")
        }
        return component
    }
    
    private var shadowComponent: ShadowComponent {
        guard let component = entity.component(ofType: ShadowComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have a ShadowComponent")
        }
        return component
    }
    
    private var interactionComponent: InteractionComponent {
        guard let component = entity.component(ofType: InteractionComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have an InteractionComponent")
        }
        return component
    }
    
    private var liftableComponent: LiftableComponent {
        guard let component = entity.component(ofType: LiftableComponent.self) else {
            fatalError("An entity assigned to CompanionLiftedState must have a LiftableComponent")
        }
        return component
    }
    
    /// Sets the companion's position based on the lifting subject.
    ///
    private func reposition() {
        // Adjust position
        guard let node = liftableComponent.liftSubject?.component(ofType: NodeComponent.self)?.node else {
            stateMachine?.enter(CompanionDeathState.self)
            return
        }
        let offset = spriteComponent.size.height / 4.0
        nodeComponent.node.position = CGPoint(x: node.position.x, y: node.position.y + offset)
        
        // Adjust depth
        let direction = liftableComponent.liftSubject!.component(ofType: DirectionComponent.self)?.direction
        switch direction {
        case .none: depthComponent.over = liftableComponent.liftSubject
        case .some(let value):
            switch value {
            case .south: depthComponent.over = liftableComponent.liftSubject
            default: depthComponent.under = liftableComponent.liftSubject
            }
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        physicsComponent.remove()
        shadowComponent.detach()
        interactionComponent.detach()
        reposition()
    }
    
    override func willExit(to nextState: GKState) {
        depthComponent.over = nil
        depthComponent.under = nil
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is CompanionHurledState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        reposition()
    }
}
