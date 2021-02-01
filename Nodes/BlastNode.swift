//
//  BlastNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UpdateNode` subclass that defines the blast node.
///
class BlastNode: UpdateNode, Identifiable, Contactable {
    
    /// An enum that defines the blast states.
    ///
    private enum State {
        case standard, beginning, end
    }
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The node representing the blast's sprite.
    ///
    private let node: SKSpriteNode
    
    /// The blast instance.
    ///
    private let blast: Blast
    
    /// The blast interaction.
    ///
    private let interaction: Interaction
    
    /// The difference between the blast's initial and final sizes.
    ///
    private let spreadSize: CGSize
    
    /// The set of targets that were hit by the blast.
    ///
    private var targetsHit: Set<String>
    
    /// The current size of the blast.
    ///
    private var currentSize: CGSize {
        didSet {
            let physicsBody = SKPhysicsBody(rectangleOf: currentSize)
            interaction.updateInteractions(onPhysicsBody: physicsBody)
            self.physicsBody = physicsBody
        }
    }
    
    /// The current state of the blast.
    ///
    private var state: State {
        didSet { elapsedTime = 0 }
    }
    
    /// The elapsed time since last state change.
    ///
    private var elapsedTime: TimeInterval
    
    /// The flag stating whether or not the blast has run its course.
    ///
    private var hasCompleted: Bool
    
    /// The entity that caused the blast.
    ///
    private weak var source: Entity?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - blast: The spreading `Blast` instance.
    ///   - origin: The origin of the blast.
    ///   - interaction: The `Interaction` to apply on the blast's physics body.
    ///   - source: The entity that caused the blast.
    ///
    init(blast: Blast, origin: CGPoint, interaction: Interaction, source: Entity?) {
        self.blast = blast
        self.interaction = interaction
        self.source = source
        targetsHit = []
        spreadSize = CGSize(width: blast.finalSize.width - blast.initialSize.width,
                            height: blast.finalSize.height - blast.initialSize.height)
        currentSize = blast.initialSize
        state = .beginning
        elapsedTime = 0
        hasCompleted = false
        node = SKSpriteNode(color: .clear, size: blast.initialSize)
        
        super.init()
        position = origin
        name = "BlastNode." + identifier
        entity = source
        addChild(node)
        
        blast.animation?.initial?.play(node: node)
        ContactNotifier.registerCallbackFor(nodeNamed: name!, callback: self)
        
        if let source = source { blast.damage?.createDamageSnapshot(from: source, using: blast.medium) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        zPosition = max(DepthLayer.contents.upperBound - 1 - (position.y - currentSize.height / 2.0),
                        DepthLayer.contents.lowerBound)
        
        switch state {
        case .beginning:
            if elapsedTime >= blast.delay {
                blast.animation?.main?.play(node: node)
                blast.sfx?.play(at: position, sceneKind: .level)
                state = .standard
            } else if hasCompleted {
                fallthrough
            }
        case .standard:
            if hasCompleted || elapsedTime >= blast.duration {
                ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
                physicsBody = nil
                blast.animation?.final?.play(node: node)
                state = .end
            } else {
                let ratio = CGFloat(elapsedTime / blast.duration)
                currentSize = CGSize(width: blast.initialSize.width + spreadSize.width * ratio,
                                     height: blast.initialSize.height + spreadSize.height * ratio)
            }
        case .end:
            if elapsedTime >= blast.conclusion {
                removeFromParent()
            } else if node.parent != nil {
                if let duration = blast.animation?.final?.duration, elapsedTime >= duration {
                    node.removeFromParent()
                }
            }
        }
    }

    func contactDidBegin(_ contact: Contact) {
        guard !hasCompleted else { return }
        
        guard let target = contact.otherBody.node?.entity as? Entity else { return }
        
        // Ignore if the target was already hit by this blast
        guard targetsHit.insert(target.identifier).inserted else { return }
        
        Combat.carryOutHostileAction(using: blast.medium, on: target, as: source,
                                     damage: blast.damage, conditions: blast.conditions)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    /// Informs the node that it was affected by a dispelling effect.
    ///
    /// If the `Blast` instance used by the node can be dispelled, `complete()` will be called to complete
    /// the execution immediately.
    ///
    func wasAffectedByDispel() {
        switch blast.medium {
        case .spell, .power:
            complete()
        default:
            break
        }
    }
    
    /// Completes the blast's execution immediately.
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
