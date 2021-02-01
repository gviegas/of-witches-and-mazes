//
//  RayNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UpdateNode` subclass that defines the ray node.
///
class RayNode: UpdateNode, Identifiable, Contactable {
    
    /// An enum that deines the ray states.
    ///
    private enum State {
        case standard, beginning, end
    }
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The node representing the ray's contact body.
    ///
    private let contactNode: SKNode
    
    /// The node representing the ray's animation.
    ///
    private let animationNode: SKSpriteNode
    
    /// The ray instance.
    ///
    private let ray: Ray
    
    /// The direction of the ray.
    ///
    private let direction: CGVector
    
    /// The ray interaction.
    ///
    private let interaction: Interaction
    
    /// The difference between the ray's initial and final sizes.
    ///
    private let extendSize: CGSize
    
    /// The set of targets that were hit by the ray.
    ///
    private var targetsHit: Set<String>
    
    /// The current size of the ray.
    ///
    private var currentSize: CGSize {
        didSet {
            let physicsBody = SKPhysicsBody(rectangleOf: currentSize)
            interaction.updateInteractions(onPhysicsBody: physicsBody)
            contactNode.physicsBody = physicsBody
            contactNode.position = CGPoint(x: currentSize.width / 2.0 * direction.dx,
                                           y: currentSize.width / 2.0 * direction.dy)
        }
    }
    
    /// The current state of the ray.
    ///
    private var state: State {
        didSet { elapsedTime = 0 }
    }
    
    /// The elapsed time since last state change.
    ///
    private var elapsedTime: TimeInterval
    
    /// A flag stating whether or not the ray has run its course.
    ///
    private var hasCompleted: Bool
    
    /// The entity that caused the ray.
    ///
    private weak var source: Entity?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - ray: The extending `Ray` instance.
    ///   - position: The initial position of the ray.
    ///   - direction: The direction to extend towards.
    ///   - zRotation: The z rotation to apply in the ray.
    ///   - interaction: The `Interaction` to apply on the ray's physics body.
    ///   - source: The entity that caused the ray.
    ///
    init(ray: Ray, position: CGPoint, direction: CGVector, zRotation: CGFloat, interaction: Interaction,
         source: Entity?) {
        
        self.ray = ray
        self.direction = direction
        self.interaction = interaction
        self.source = source
        targetsHit = []
        extendSize = CGSize(width: ray.finalSize.width - ray.initialSize.width,
                            height: ray.finalSize.height - ray.initialSize.height)
        currentSize = ray.initialSize
        state = .beginning
        elapsedTime = 0
        hasCompleted = false
        contactNode = SKNode()
        animationNode = SKSpriteNode(color: .clear, size: ray.initialSize)
        
        contactNode.zRotation = zRotation
        animationNode.zRotation = zRotation
        
        super.init()
        self.position = position
        addChild(contactNode)
        addChild(animationNode)
        
        ray.animation?.initial?.play(node: animationNode)
        
        name = "RayNode." + identifier
        entity = source
        contactNode.name = name!
        ContactNotifier.registerCallbackFor(nodeNamed: name!, callback: self)
        
        if let source = source { ray.damage?.createDamageSnapshot(from: source, using: ray.medium) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        zPosition = max(DepthLayer.contents.upperBound - 1 - (position.y + animationNode.frame.minY),
                        DepthLayer.contents.lowerBound)
        
        switch state {
        case .beginning:
            if elapsedTime >= ray.delay {
                ray.animation?.main?.play(node: animationNode)
                ray.sfx?.play(at: position, sceneKind: .level)
                state = .standard
            } else if hasCompleted {
                fallthrough
            }
        case .standard:
            if hasCompleted || elapsedTime >= ray.duration {
                ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
                contactNode.removeFromParent()
                ray.animation?.final?.play(node: animationNode)
                state = .end
            } else {
                let ratio = CGFloat(elapsedTime / ray.duration)
                currentSize = CGSize(width: ray.initialSize.width + extendSize.width * ratio,
                                     height: ray.initialSize.height + extendSize.height * ratio)
            }
        case .end:
            if elapsedTime >= ray.conclusion {
                removeFromParent()
            } else if animationNode.parent != nil {
                if let duration = ray.animation?.final?.duration, elapsedTime >= duration {
                    animationNode.removeFromParent()
                }
            }
        }
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard !hasCompleted else { return }
        
        guard let target = contact.otherBody.node?.entity as? Entity else { return }

        // Ignore if the target was already hit by this ray
        guard targetsHit.insert(target.identifier).inserted else { return }
        
        Combat.carryOutHostileAction(using: ray.medium, on: target, as: source,
                                     damage: ray.damage, conditions: ray.conditions)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    /// Informs the node that it was affected by a dispelling effect.
    ///
    /// If the `Ray` instance used by the node can be dispelled, `complete()` will be called to complete
    /// the execution immediately.
    ///
    func wasAffectedByDispel() {
        switch ray.medium {
        case .spell, .power:
            complete()
        default:
            break
        }
    }
    
    /// Completes the ray's execution immediately.
    ///
    func complete() {
        hasCompleted = true
    }
    
    override func terminate() {
        ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
        removeFromParent()
        hasCompleted = true
        state = .end
    }
}
