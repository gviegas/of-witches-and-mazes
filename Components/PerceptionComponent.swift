//
//  PerceptionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/10/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the perception delegate, used by the `PerceptionComponent` when
/// it becomes aware of a target.
///
protocol PerceptionDelegate: AnyObject {
    
    /// Informs the delegate that a target was perceived.
    ///
    /// - Parameter target: The entity that was perceived.
    ///
    func didPerceiveTarget(_ target: Entity)
}

/// An enum that defines perception radius values.
///
enum PerceptionRadius {
    case veryNear, average, farAway, other(CGFloat)
    
    /// The radius value.
    ///
    var radiusValue: CGFloat {
        let value: CGFloat
        switch self {
        case .veryNear:
            value = 140.0
        case .average:
            value = 420.0
        case .farAway:
            value = 700.0
        case .other(let radius):
            value = max(1.0, radius)
        }
        return value
    }
}

/// A component that provides an entity with a perception node, enabling it to become aware
/// of nearby targets.
///
class PerceptionComponent: Component, Contactable {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a PerceptionComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The perception's refresh time.
    ///
    private static let refreshTime: TimeInterval = 1.0
    
    /// The perception node.
    ///
    private let node: SKNode
    
    /// The elapsed time since last refresh.
    ///
    private var elapsedTime: TimeInterval
    
    /// The perception interaction.
    ///
    var interaction: Interaction {
        didSet {
            guard let physicsBody = node.physicsBody else { return }
            interaction.updateInteractions(onPhysicsBody: physicsBody)
        }
    }
    
    /// The perception delegate, called when a target is perceived.
    ///
    weak var delegate: PerceptionDelegate?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: An `Interaction` type defining the targets.
    ///   - radius: The perception radius.
    ///   - delegate: An optional `PerceptionDelegate` to be called when a target is perceived.
    ///
    init(interaction: Interaction, radius: CGFloat, delegate: PerceptionDelegate?) {
        node = SKNode()
        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        interaction.updateInteractions(onPhysicsBody: physicsBody)
        node.physicsBody = physicsBody
        self.interaction = interaction
        self.delegate = delegate
        elapsedTime = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the perception node to the entity's node.
    ///
    /// If the perception node is already attached, this method has no effect.
    ///
    func attach() {
        if node.parent == nil, let entity = entity {
            let id = (entity as? Entity)?.identifier ?? "\(ObjectIdentifier(entity))"
            node.name = "PerceptionComponent." + id
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
    
    /// Detaches the perception node from the entity's node.
    ///
    /// If the perception node is not attached, this method has no effect.
    ///
    func detach() {
        if let _ = node.parent {
            ContactNotifier.removeCallbackFor(nodeNamed: node.name!, callback: self)
            node.removeFromParent()
            node.constraints = nil
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        guard let _ = node.parent, elapsedTime >= PerceptionComponent.refreshTime else { return }
        
        node.removeFromParent()
        nodeComponent.node.addChild(node)
        elapsedTime = 0
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard let delegate = delegate,
            let target = contact.otherBody.node?.entity as? Entity,
            !(contact.otherBody.node is AuraNode),
            target.component(ofType: ConcealmentComponent.self)?.isConcealed != true
            else { return }
        
        delegate.didPerceiveTarget(target)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
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
