//
//  InfluenceNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/15/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UpdateNode` subclass that defines the influence node.
///
class InfluenceNode: UpdateNode, Identifiable, Contactable {
    
    /// An enum defining the influence's states.
    ///
    private enum State {
        case beginning, standard, end
    }
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The node representing the influence's sprite.
    ///
    private let node: SKSpriteNode
    
    /// The influence instance.
    ///
    private let influence: Influence
    
    /// The set of targets that were affected by the influence.
    ///
    private var targetsAffected: Set<String>
    
    /// The elapsed time since the last state change.
    ///
    private var elapsedTime: TimeInterval
    
    /// The current state of the influence.
    ///
    private var state: State {
        didSet { elapsedTime = 0 }
    }
    
    /// The entity that caused the influence.
    ///
    private weak var source: Entity?
    
    /// Creates a new instance form the given values.
    ///
    /// - Parameters:
    ///   - influence: The `Influence` instance for which to create the node.
    ///   - origin: The origin of the influence.
    ///   - source: The entity that caused the influence.
    ///
    init(influence: Influence, origin: CGPoint, source: Entity?) {
        self.influence = influence
        self.source = source
        targetsAffected = []
        elapsedTime = 0
        state = .beginning
        
        let size = CGSize(width: influence.radius * 2.0, height: influence.radius * 2.0)
        node = SKSpriteNode(color: .clear, size: size)
        
        super.init()
        position = origin
        name = "InfluenceNode." + identifier
        entity = source
        addChild(node)
        
        ContactNotifier.registerCallbackFor(nodeNamed: name!, callback: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        switch state {
        case .beginning:
            if elapsedTime >= influence.delay {
                physicsBody = SKPhysicsBody(circleOfRadius: influence.radius)
                influence.interaction.updateInteractions(onPhysicsBody: physicsBody!)
                influence.animation?.play(node: node)
                influence.sfx?.play(at: position, sceneKind: .level)
                state = .standard
            }
        case .standard:
            if elapsedTime >= influence.duration {
                physicsBody = nil
                state = .end
            }
        case .end:
            if elapsedTime >= influence.conclusion {
                ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
                removeFromParent()
            }
        }
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard let targetNode = contact.otherBody.node else { return }
        
        // Ignore if the target was already affected by this influence
        let targetIdentifier = "\(ObjectIdentifier(targetNode))"
        guard targetsAffected.insert(targetIdentifier).inserted else { return }
        
        influence.didInfluence(node: targetNode, source: source)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    /// Completes the influence's execution immediately.
    ///
    func complete() {
        state = .end
    }
    
    override func terminate() {
        ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
        removeFromParent()
        state = .end
    }
}
