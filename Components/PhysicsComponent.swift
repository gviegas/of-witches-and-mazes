//
//  PhysicsComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/1/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that defines the interaction area of a physics body.
///
enum PhysicsShape {
    case circle(radius: CGFloat, center: CGPoint)
    case rectangle(size: CGSize, center: CGPoint)
}

/// A component that enables an entity to participate in the physics simulation.
///
class PhysicsComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a PhysicsComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The physics body of the entity.
    ///
    private let physicsBody: SKPhysicsBody
    
    /// The shape of the physics body, defining the area to be considered for collisions and contacts.
    ///
    let physicsShape: PhysicsShape
    
    /// The position of the physics body.
    ///
    var position: CGPoint {
        let nodePosition = nodeComponent.node.position
        let physicsCenter: CGPoint
        
        switch physicsShape {
        case .circle(_, let center):
            physicsCenter = center
        case .rectangle(_, let center):
            physicsCenter = center
        }
        
        return CGPoint(x: nodePosition.x + physicsCenter.x, y: nodePosition.y + physicsCenter.y)
    }
    
    /// The interaction to be applied to the physics body.
    ///
    var interaction: Interaction {
        didSet {
            interaction.updateInteractions(onPhysicsBody: physicsBody)
        }
    }
    
    /// The entities currently in contact.
    ///
    var contactedEntities: [Entity] {
        var entities = [Entity]()
        for other in physicsBody.allContactedBodies() {
            guard let contact = other.node?.entity as? Entity else { continue }
            guard let contactMainNode = contact.component(ofType: NodeComponent.self)?.node else { continue }
            guard contactMainNode === other.node else { continue }
            if Interaction.hasInterest(physicsBody, in: other) || Interaction.hasInterest(other, in: physicsBody) {
                entities.append(contact)
            }
        }
        return entities
    }
    
    /// The callback to receive contact notifications.
    ///
    weak var contactable: Contactable? {
        willSet {
            if let contactable = contactable, let name = nodeComponent.node.name {
                ContactNotifier.removeCallbackFor(nodeNamed: name, callback: contactable)
            }
            if let newValue = newValue, let name = nodeComponent.node.name {
                ContactNotifier.registerCallbackFor(nodeNamed: name, callback: newValue)
            }
        }
    }
    
    /// Creates a new instance from the given `PhysicsShape` and `Interaction` values.
    ///
    /// - Parameters:
    ///   - physicsShape: The `PhysicsShape` to use.
    ///   - interaction: The `Interaction` instance that defines which things to interact with.
    ///
    init(physicsShape: PhysicsShape, interaction: Interaction) {
        self.physicsShape = physicsShape
        self.interaction = interaction
       
        switch physicsShape {
        case .circle(let radius, let center):
            physicsBody = SKPhysicsBody(circleOfRadius: radius, center: center)
        case .rectangle(let size, let center):
            physicsBody = SKPhysicsBody(rectangleOf: size, center: center)
        }
        
        physicsBody.pinned = true
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.friction = 0
        physicsBody.restitution = 0
        physicsBody.linearDamping = 0
        physicsBody.angularDamping = 0
        interaction.updateInteractions(onPhysicsBody: physicsBody)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Assigns the physics body to the entity's node.
    ///
    func assign() {
        nodeComponent.node.physicsBody = physicsBody
    }
    
    /// Removes the physics body from the entity's node.
    ///
    func remove() {
        nodeComponent.node.physicsBody = nil
    }
    
    /// Pins the physics body.
    ///
    func pin() {
        physicsBody.pinned = true
    }
    
    /// Unpins the physics body.
    ///
    func unpin() {
        physicsBody.pinned = false
    }
    
    override func didAddToEntity() {
        assign()
    }
    
    override func willRemoveFromEntity() {
        remove()
    }
}
