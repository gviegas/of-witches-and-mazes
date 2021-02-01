//
//  StealthComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to enter stealth mode.
///
class StealthComponent: Component, Contactable {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a StealthComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var movementComponent: MovementComponent {
        guard let component = entity?.component(ofType: MovementComponent.self) else {
            fatalError("An entity with a StealthComponent must also have a MovementComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a StealthComponent must also have a SpriteComponent")
        }
        return component
    }
    
    private var stateComponent: StateComponent {
        guard let component = entity?.component(ofType: StateComponent.self) else {
            fatalError("An entity with a StealthComponent must also have a StateComponent")
        }
        return component
    }
    
    private var concealmentComponent: ConcealmentComponent {
        guard let component = entity?.component(ofType: ConcealmentComponent.self) else {
            fatalError("An entity with a StealthComponent must also have a ConcealmentComponent")
        }
        return component
    }
    
    /// The refresh time of the stealth's detection node.
    ///
    private static let refreshTime: TimeInterval = 1.5
    
    /// The modifier applied to movement speed while in stealth mode.
    ///
    private static let speedMultiplier: CGFloat = -0.5
    
    /// The detection node.
    ///
    private let detectionNode: SKNode
    
    /// The elapsed time since last refresh.
    ///
    private var elapsedTime: TimeInterval
    
    /// The private backing for the `isActive` getter.
    ///
    private var active: Bool
    
    /// The flag stating whether the entity has entered stealth mode.
    ///
    var isActive: Bool { return active }
    
    /// The interaction for the detection node.
    ///
    var detectionInteraction: Interaction {
        didSet {
            guard let physicsBody = detectionNode.physicsBody else { return }
            detectionInteraction.updateInteractions(onPhysicsBody: physicsBody)
        }
    }
    
    /// Creates a new instance from the given interaction and detection radius.
    ///
    /// - Parameters:
    ///   - detectionInteraction: An `Interaction` type defining who may detect the entity.
    ///   - detectionRadius: The detection radius.
    ///
    init(detectionInteraction: Interaction, detectionRadius: CGFloat) {
        detectionNode = SKNode()
        elapsedTime = 0
        active = false
        self.detectionInteraction = detectionInteraction
        detectionNode.physicsBody = SKPhysicsBody(circleOfRadius: detectionRadius)
        detectionInteraction.updateInteractions(onPhysicsBody: detectionNode.physicsBody!)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the detection node to the entity's node.
    ///
    /// If the detection node is already attached, this method has no effect.
    ///
    private func attach() {
        if detectionNode.parent == nil, let entity = entity {
            let id = (entity as? Entity)?.identifier ?? "\(ObjectIdentifier(entity))"
            detectionNode.name = "StealthComponent." + id
            ContactNotifier.registerCallbackFor(nodeNamed: detectionNode.name!, callback: self)
            nodeComponent.node.addChild(detectionNode)
            
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
                detectionNode.constraints = [constraint]
            }
        }
    }
    
    /// Detaches the detection node from the entity's node.
    ///
    /// If the detection node is not attached, this method has no effect.
    ///
    private func detach() {
        if let _ = detectionNode.parent {
            ContactNotifier.removeCallbackFor(nodeNamed: detectionNode.name!, callback: self)
            detectionNode.removeFromParent()
            detectionNode.constraints = nil
        }
    }
    
    /// Enters into stealth mode.
    ///
    func enterStealthMode() {
        guard !active else { return }
        
        movementComponent.modifyMultiplier(by: StealthComponent.speedMultiplier)
        concealmentComponent.increaseConcealment()
        spriteComponent.colorize(colorAnimation: .concealed)
        SoundFXSet.FX.hide.play(at: nodeComponent.node.position, sceneKind: .level)
        attach()
        active = true
    }
    
    /// Exits from stealth mode.
    ///
    func exitStealthMode() {
        guard active else { return }
        
        movementComponent.modifyMultiplier(by: -StealthComponent.speedMultiplier)
        concealmentComponent.decreaseConcealment()
        spriteComponent.colorize(colorAnimation: .revealed)
        detach()
        active = false
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        
        guard let _ = detectionNode.parent, elapsedTime >= StealthComponent.refreshTime else { return }
        
        detectionNode.removeFromParent()
        nodeComponent.node.addChild(detectionNode)
        elapsedTime = 0
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard active, let entity = entity else { return }
        
        switch entity {
        case is Protagonist:
            stateComponent.enter(stateClass: ProtagonistStandardState.self)
        default:
            break
        }
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    override func didAddToEntity() {
        detectionNode.entity = entity
    }
    
    override func willRemoveFromEntity() {
        detectionNode.entity = nil
        detach()
    }
    
    deinit {
        detectionNode.removeFromParent()
        detectionNode.constraints = nil
    }
}
