//
//  InanimateObjectHurledState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/19/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of an `InanimateObject` when hurled.
///
class InanimateObjectHurledState: EntityState, Contactable {

    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to InanimateObjectHurledState must have a NodeComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to InanimateObjectHurledState must have a PhysicsComponent")
        }
        return component
    }
    
    private var interactionComponent: InteractionComponent {
        guard let component = entity.component(ofType: InteractionComponent.self) else {
            fatalError("An entity assigned to InanimateObjectHurledState must have an InteractionComponent")
        }
        return component
    }
    
    private var liftableComponent: LiftableComponent {
        guard let component = entity.component(ofType: LiftableComponent.self) else {
            fatalError("An entity assigned to InanimateObjectHurledState must have a LiftableComponent")
        }
        return component
    }
    
    /// The target point.
    ///
    private var target = CGPoint.zero
    
    /// The origin point.
    ///
    private var origin = CGPoint.zero
    
    /// The direction vector.
    ///
    private var direction = CGVector.zero
    
    /// The maximum distance to travel.
    ///
    private var distance: CGFloat = 525.0 {
        didSet { distance = min(distance, 525.0) }
    }
    
    /// The travelling speed.
    ///
    private var speed: CGFloat = 525.0
    
    /// The temporary store for the entity's original interaction.
    ///
    private var originalInteraction: Interaction!
    
    override func didEnter(from previousState: GKState?) {
        guard let target = liftableComponent.hurlTarget,
            let hurlInteraction = liftableComponent.hurlInteraction else
        {
            stateMachine?.enter(InanimateObjectDeathState.self)
            return
        }
        
        self.target = target
        origin = nodeComponent.node.position
        let point = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
        let length = max(1.0, (point.x * point.x + point.y * point.y).squareRoot())
        direction = CGVector(dx: point.x / length, dy: point.y / length)
        distance = length
        
        originalInteraction = physicsComponent.interaction
        physicsComponent.interaction = hurlInteraction
        physicsComponent.contactable = self
        physicsComponent.assign()
        physicsComponent.unpin()
    }
    
    override func willExit(to nextState: GKState) {
        interactionComponent.attach()
        physicsComponent.interaction = originalInteraction
        physicsComponent.contactable = nil
        physicsComponent.pin()
        liftableComponent.liftSubject = nil
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is InanimateObjectStandardState.Type || stateClass is InanimateObjectDeathState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let tx = direction.dx * speed * CGFloat(seconds)
        let ty = direction.dy * speed * CGFloat(seconds)
        nodeComponent.node.position.x += tx
        nodeComponent.node.position.y += ty
        
        let point = CGPoint(x: nodeComponent.node.position.x - origin.x,
                            y: nodeComponent.node.position.y - origin.y)
        
        guard (point.x * point.x + point.y * point.y).squareRoot() < distance else {
            stateMachine?.enter(InanimateObjectStandardState.self)
            return
        }
    }
    
    func contactDidBegin(_ contact: Contact) {
        if let other = contact.otherBody.node?.entity as? Entity, let damage = liftableComponent.hurlDamage {
            Combat.carryOutHostileAction(using: .none, on: other, as: liftableComponent.liftSubject, damage: damage,
                                         conditions: nil)
            Combat.carryOutHostileAction(using: .none, on: entity, as: nil, damage: damage, conditions: nil)
        }
        stateMachine?.enter(InanimateObjectStandardState.self)
    }
    
    func contactDidEnd(_ contact: Contact) {
    
    }
}
