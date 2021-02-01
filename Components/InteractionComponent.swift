//
//  InteractionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/18/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the interaction delegate, called by the `InteractionComponent`
/// when an interaction takes place.
///
protocol InteractionDelegate: AnyObject {
    
    /// Informs the delegate that an interaction took place.
    ///
    /// - Parameter entity: The entity to interact with.
    ///
    func didInteractWith(entity: Entity)
}

/// A component that enables an entity to become interactive.
///
class InteractionComponent: Component, Contactable {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with an InteractioComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The interaction node.
    ///
    private let node: SKNode
    
    /// The text describing the interaction.
    ///
    private let text: String
    
    /// The current entity inside the interaction radius.
    ///
    private weak var subject: Entity?
    
    /// The delegate to call on interaction.
    ///
    weak var delegate: InteractionDelegate?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: The `Interaction` that defines the contactable targets.
    ///   - radius: The interaction radius around the entity's sprite.
    ///   - text: A short text that describes the interaction outcome.
    ///   - delegate: An optional `InteractionDelegate` to set on creation.
    ///
    init(interaction: Interaction, radius: CGFloat, text: String, delegate: InteractionDelegate?) {
        node = SKNode()
        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        interaction.updateInteractions(onPhysicsBody: physicsBody)
        node.physicsBody = physicsBody
        self.text = text
        self.delegate = delegate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the interaction node to the entity's node.
    ///
    /// If the interaction node is already attached, this method has no effect.
    ///
    func attach() {
        if node.parent == nil, let entity = entity {
            let id = (entity as? Entity)?.identifier ?? "\(ObjectIdentifier(entity))"
            node.name = "InteractionComponent." + id
            ContactNotifier.registerCallbackFor(nodeNamed: node.name!, callback: self)
            nodeComponent.node.addChild(node)
            
            if let physicsShape = entity.component(ofType: PhysicsComponent.self)?.physicsShape {
                let position: CGPoint
                switch physicsShape {
                case .circle(_, let center):
                    position = center
                case .rectangle(_, let center):
                    position = center
                }
                let rangeX = SKRange(constantValue: position.x)
                let rangeY = SKRange(constantValue: position.y)
                let constraint = SKConstraint.positionX(rangeX, y: rangeY)
                constraint.referenceNode = nodeComponent.node
                node.constraints = [constraint]
            }
        }
    }
    
    /// Detaches the interaction node from the entity's node.
    ///
    /// If the interaction node is not attached, this method has no effect.
    ///
    func detach() {
        if let _ = node.parent {
            ContactNotifier.removeCallbackFor(nodeNamed: node.name!, callback: self)
            node.removeFromParent()
            node.constraints = nil
            if let entity = entity as? Entity {
                subject?.component(ofType: SubjectComponent.self)?.removeSubject(entity)
            }
            subject = nil
        }
    }
    
    /// Interacts with the component.
    ///
    /// - Parameter entity: The entity that started the interaction.
    ///
    func interactWith(entity: Entity) {
        delegate?.didInteractWith(entity: entity)
    }
    
    /// Notifies the component that it is now the current subject.
    ///
    func willBecomeCurrent() {
        guard entity?.component(ofType: HealthComponent.self)?.isDead != true else { return }
        guard let scene = SceneManager.levelScene else { return }
        
        scene.optionOverlay = OptionOverlay(rect: scene.frame, options: [(.key(.interact), text)])
    }
    
    /// Notifies the component that it will no longer be the current subject.
    ///
    func willRemoveCurrent() {
        SceneManager.levelScene?.optionOverlay = nil
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard
            let target = contact.otherBody.node?.entity as? Entity,
            let subjectComponent = target.component(ofType: SubjectComponent.self),
            let entity = entity as? Entity
            else { return }
        
        subject = target
        subjectComponent.addSubject(entity)
    }
    
    func contactDidEnd(_ contact: Contact) {
        guard
            let target = contact.otherBody.node?.entity as? Entity,
            let subjectComponent = target.component(ofType: SubjectComponent.self),
            let entity = entity as? Entity
            else { return }
        
        subject = nil
        subjectComponent.removeSubject(entity)
    }
    
    override func didAddToEntity() {
        node.entity = entity
        attach()
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        detach()
    }
    
    deinit {
        node.removeFromParent()
        node.constraints = nil
    }
}
