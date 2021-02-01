//
//  MissileNode.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UpdateNode` subclass that defines the missile node.
///
class MissileNode: UpdateNode, Identifiable, Contactable {
    
    /// An enum that defines the missile states.
    ///
    private enum State {
        case standard, beginning, end
    }
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The node representing the missile's sprite.
    ///
    private let node: SKSpriteNode
    
    /// The missile instance.
    ///
    private let missile: Missile
    
    /// The direction that the missile is moving.
    ///
    private let direction: CGVector
    
    /// The total distance moved.
    ///
    private var displacement: CGVector
    
    /// The set of targets that were hit by the missile.
    ///
    private var targetsHit: Set<String>
    
    /// A flag stating whether or not the missile has run its course.
    ///
    private var hasCompleted: Bool
    
    /// The elapsed time since the last state change.
    ///
    private var elapsedTime: TimeInterval
    
    /// The current state of the missile.
    ///
    private var state: State {
        didSet { elapsedTime = 0 }
    }
    
    /// The entity that propelled the missile.
    ///
    private weak var source: Entity?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - missile: The propelled `Missile` instance.
    ///   - position: The initial position of the missile.
    ///   - direction: The direction propelled.
    ///   - zRotation: The z rotation to apply in the missile.
    ///   - interaction: The `Interaction` to apply on the missile's physics body.
    ///   - source: The entity that propelled the missile.
    ///
    init(missile: Missile, position: CGPoint, direction: CGVector, zRotation: CGFloat, interaction: Interaction,
         source: Entity?) {
        
        self.missile = missile
        self.direction = direction
        self.source = source
        displacement = CGVector.zero
        targetsHit = []
        hasCompleted = false
        elapsedTime = 0
        state = .beginning
        node = SKSpriteNode(color: .clear, size: missile.size)
        
        super.init()
        let physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        interaction.updateInteractions(onPhysicsBody: physicsBody)
        self.physicsBody = physicsBody
        self.position = position
        self.zRotation = zRotation
        name = "MissileNode." + identifier
        entity = source
        addChild(node)
        
        if let initialAnimation = missile.animation?.initial {
            initialAnimation.play(node: node)
        } else {
            missile.animation?.main?.play(node: node)
            state = .standard
        }
        missile.sfx?.play(at: position, sceneKind: .level)
        ContactNotifier.registerCallbackFor(nodeNamed: name!, callback: self)
        
        if let source = source { missile.damage?.createDamageSnapshot(from: source, using: missile.medium) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        switch state {
        case .beginning:
            let duration = missile.animation?.initial?.duration ?? 0
            if elapsedTime >= duration {
                missile.animation?.main?.play(node: node)
                state = .standard
            } else if hasCompleted {
                fallthrough
            }
        case .standard:
            if hasCompleted {
                ContactNotifier.removeCallbackFor(nodeNamed: name!, callback: self)
                missile.animation?.final?.play(node: node)
                state = .end
            }
        case .end:
            let duration = missile.animation?.final?.duration ?? 0
            if elapsedTime >= duration {
                removeFromParent()
            }
        }
        
        guard !hasCompleted else { return }
        
        let tx = direction.dx * missile.speed * CGFloat(seconds)
        let ty = direction.dy * missile.speed * CGFloat(seconds)
        displacement.dx += tx
        displacement.dy += ty
        position.x += tx
        position.y += ty
        
        let d = (displacement.dx * displacement.dx + displacement.dy * displacement.dy).squareRoot()
        hasCompleted = d >= missile.range
        
        zPosition = max(DepthLayer.contents.upperBound - 1 - (position.y - missile.size.height / 2.0),
                        DepthLayer.contents.lowerBound)
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard !hasCompleted, let physicsBody = contact.otherBody.node?.physicsBody else { return }
        
        // Set as completed if the missile dissipates on hit or the contact is an obstacle
        if missile.dissipateOnHit || Interaction.isObstacle(physicsBody: physicsBody) { hasCompleted = true }
        
        guard let target = contact.otherBody.node?.entity as? Entity else { return }
        
        // Ignore if the target was already hit by this missile
        guard targetsHit.insert(target.identifier).inserted else { return }
        
        Combat.carryOutHostileAction(using: missile.medium, on: target, as: source,
                                     damage: missile.damage, conditions: missile.conditions)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    /// Informs the node that it was affected by a dispelling effect.
    ///
    /// If the `Missile` instance used by the node can be dispelled, `complete()` will be called to complete
    /// the execution immediately.
    ///
    func wasAffectedByDispel() {
        switch missile.medium {
        case .spell, .power:
            complete()
        default:
            break
        }
    }
    
    /// Completes the missile's execution immediately.
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
