//
//  ThrowingNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/17/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UpdateNode` subclass that defines the throwing node.
///
class ThrowingNode: UpdateNode, Identifiable, Contactable {
    
    /// An enum that defines the throwing states.
    ///
    private enum State {
        case beginning, standard, end
    }
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The node representing the throwing's sprite.
    ///
    private let node: SKSpriteNode
    
    /// The throwing instance.
    ///
    private let throwing: Throwing
    
    /// The direction of the movement.
    ///
    private let direction: CGVector
    
    /// The total distance to travel.
    ///
    private let distance: CGFloat
    
    /// The total distance traveled.
    ///
    private var traveled: CGFloat
    
    /// The set of targets that were contacted by the throwing.
    ///
    private var targetsContacted: Set<String>
    
    /// The elapsed time since the last state change.
    ///
    private var elapsedTime: TimeInterval
    
    /// The flag stating if the throwing has completed.
    ///
    private var hasCompleted: Bool
    
    /// The current throwing state.
    ///
    private var state: State {
        didSet { elapsedTime = 0 }
    }
    
    /// The entity that threw.
    ///
    private weak var source: Entity?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - throwing: The `Throwing` instance.
    ///   - origin: The initial position of the throwing.
    ///   - target: The final position of the throwing.
    ///   - source: The entity that threw.
    ///
    init(throwing: Throwing, origin: CGPoint, target: CGPoint, source: Entity?) {
        self.throwing = throwing
        self.source = source
        traveled = 0
        targetsContacted = []
        elapsedTime = 0
        state = .beginning
        hasCompleted = false
        node = SKSpriteNode(color: .clear, size: throwing.size)
        
        let p = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
        distance = min((p.x * p.x + p.y * p.y).squareRoot(), throwing.range)
        direction = CGVector(dx: p.x / distance , dy: p.y / distance)
        
        super.init()
        if throwing.isRotational { self.zRotation = atan2(p.y, p.x) }
        position = origin
        physicsBody = SKPhysicsBody(rectangleOf: throwing.size)
        throwing.interaction.updateInteractions(onPhysicsBody: physicsBody!)
        name = "ThrowingNode." + identifier
        entity = source
        addChild(node)
        
        if let initialAnimation = throwing.animation?.initial {
            initialAnimation.play(node: node)
        } else {
            throwing.animation?.main?.play(node: node)
            state = .standard
        }
        throwing.sfx?.play(at: position, sceneKind: .level)
        ContactNotifier.registerCallbackFor(nodeNamed: name!, callback: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        switch state {
        case .beginning:
            let duration = throwing.animation?.initial?.duration ?? 0
            if elapsedTime >= duration {
                throwing.animation?.main?.play(node: node)
                state = .standard
            } else if hasCompleted {
                fallthrough
            }
        case .standard:
            if hasCompleted {
                ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
                throwing.animation?.final?.play(node: node)
                state = .end
                throwing.didReachDestination(position, totalContacts: targetsContacted.count, source: source)
            }
        case .end:
            let duration = throwing.animation?.final?.duration ?? 0
            if elapsedTime >= duration {
                removeFromParent()
            }
        }
        
        guard !hasCompleted else { return }
        
        let dx = direction.dx * CGFloat(seconds) * throwing.speed
        let dy = direction.dy * CGFloat(seconds) * throwing.speed
        position.x += dx
        position.y += dy
        traveled += (dx * dx + dy * dy).squareRoot()
        hasCompleted = traveled >= distance
        
        zPosition = max(DepthLayer.contents.upperBound - 1 - (position.y - throwing.size.height / 2.0),
                        DepthLayer.contents.lowerBound)
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard !hasCompleted, let physicsBody = contact.otherBody.node?.physicsBody else { return }
        
        // Set as completed if the throwing contacts only once or the contact is an obstacle
        if throwing.completeOnContact || Interaction.isObstacle(physicsBody: physicsBody) { hasCompleted = true }
        
        let targetNode = contact.otherBody.node!
        
        // Ignore if the target was already contacted by this throwing
        let targetIdentifier = "\(ObjectIdentifier(targetNode))"
        guard targetsContacted.insert(targetIdentifier).inserted else { return }
        
        throwing.didContact(node: targetNode, location: position, source: source)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    /// Completes the throwing execution immediately.
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
