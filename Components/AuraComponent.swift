//
//  AuraComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `SKNode` subclass that identifies nodes representing `Aura` effects.
///
class AuraNode: SKNode {}

/// A component that provides an entity with an aura that affects contacted targets.
///
class AuraComponent: Component, Contactable {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with an AuraComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The detach animation.
    ///
    private static let detachAnimation = SKAction.sequence([.fadeOut(withDuration: 1.0), .removeFromParent()])
    
    /// The node representing the aura.
    ///
    private let node: AuraNode
    
    /// The total time since the current aura was set. This value is only incremented for auras that
    /// have a `duration`.
    ///
    private var totalTime: TimeInterval
    
    /// The elpased time since last aura refresh.
    ///
    private var elapsedTime: TimeInterval
    
    /// The interaction for the auras.
    ///
    private var interaction: Interaction {
        didSet {
            if let physicsBody = physicsBody {
                interaction.updateInteractions(onPhysicsBody: physicsBody)
            }
        }
    }
    
    /// The physics body of the aura node.
    ///
    private var physicsBody: SKPhysicsBody? {
        didSet {
            node.physicsBody = physicsBody
            if let physicsBody = physicsBody {
                interaction.updateInteractions(onPhysicsBody: physicsBody)
            }
        }
    }
    
    /// The aura to apply.
    ///
    var aura: Aura? {
        didSet {
            // Remove the children from previous aura
            node.removeAllChildren()
            totalTime = 0
            if let aura = aura {
                // Refresh the aura immediately
                elapsedTime = aura.refreshTime
                if let animation = aura.animation {
                    // Add the new animation
                    let sprite = SKSpriteNode(texture: nil, size: CGSize(width: aura.radius * 2.0,
                                                                         height: aura.radius * 2.0))
                    animation.play(node: sprite)
                    node.addChild(sprite)
                    if aura.alwaysInFront { node.zPosition = DepthLayer.contents.upperBound - 1 }
                }
                // Play the sound effect
                aura.sfx?.play(at: nodeComponent.node.position, sceneKind: .level)
            }
        }
    }
    
    /// Create a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: The `Interaction` instance that defines which targets should be affected.
    ///   - aura: An optional `Aura` instance to set on creation. The default value is `nil`.
    ///
    init(interaction: Interaction, aura: Aura? = nil) {
        self.interaction = interaction
        self.aura = aura
        node = AuraNode()
        totalTime = 0
        elapsedTime = aura?.refreshTime ?? 0
        super.init()
        
        if let aura = aura, let animation = aura.animation {
            let sprite = SKSpriteNode(texture: nil, size: CGSize(width: aura.radius * 2.0,
                                                                 height: aura.radius * 2.0))
            animation.play(node: sprite)
            node.addChild(sprite)
            if aura.alwaysInFront { node.zPosition = DepthLayer.contents.upperBound - 1 }
        }
        
        // Note: The sound effect won't be played, since the entity's position is still unknown at this point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the aura node to the entity's node.
    ///
    /// If the aura node is already attached, this method has no effect.
    ///
    func attach() {
        node.alpha = 1.0
        if node.parent == nil, let entity = entity {
            let id = (entity as? Entity)?.identifier ?? "\(ObjectIdentifier(entity))"
            node.name = "AuraComponent." + id
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
    
    /// Detaches the aura node from the entity's node.
    ///
    /// If the aura node is not attached, this method has no effect.
    ///
    /// - Parameter withFadeEffect: A flag stating whether the node should play a fade out animation
    ///   before detaching itself from the entity. The default value is `false`.
    ///
    func detach(withFadeEffect: Bool = false) {
        guard node.parent != nil else { return }
        
        ContactNotifier.removeCallbackFor(nodeNamed: node.name!, callback: self)
        if withFadeEffect {
            node.run(AuraComponent.detachAnimation) { [unowned self] in self.node.constraints = nil }
        } else {
            node.removeFromParent()
            node.constraints = nil
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let aura = aura else { return }
        
        elapsedTime += seconds
        if elapsedTime >= aura.refreshTime {
            physicsBody = SKPhysicsBody(circleOfRadius: aura.radius)
            elapsedTime = 0
        }
        
        if !aura.alwaysInFront {
            node.zPosition = max(DepthLayer.contents.upperBound - 1 - node.position.y, DepthLayer.contents.lowerBound)
        }
        
        guard let duration = aura.duration else { return }
        
        totalTime += seconds
        if totalTime >= duration { self.aura = nil }
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard let aura = aura, let target = contact.otherBody.node?.entity as? Entity else { return }
        
        if aura.isHostile {
            Combat.carryOutHostileAction(using: .none, on: target, as: entity as? Entity,
                                         damage: aura.damage, conditions: aura.conditions)
        } else {
            Combat.carryOutFriendlyAction(using: .none, on: target, as: entity as? Entity,
                                          healing: aura.healing, conditions: aura.conditions)
        }
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
