//
//  AttackComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/7/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to execute attacks.
///
class AttackComponent: Component, Contactable {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with an AttackComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var directionComponent: DirectionComponent {
        guard let component = entity?.component(ofType: DirectionComponent.self) else {
            fatalError("An entity with an AttackComponent must also have a DirectionComponent")
        }
        return component
    }
    
    /// The interaction type for the attack (i.e., who will be hit).
    ///
    private var interaction: Interaction {
        didSet {
            if let physicsBody = physicsBody {
                interaction.updateInteractions(onPhysicsBody: physicsBody)
            }
        }
    }
    
    /// The physics body of the attack node.
    ///
    private var physicsBody: SKPhysicsBody? {
        didSet {
            node.physicsBody = physicsBody
            if let physicsBody = physicsBody {
                interaction.updateInteractions(onPhysicsBody: physicsBody)
            }
        }
    }
    
    /// The node representing the attack.
    ///
    private let node: SKNode
    
    /// The amount of time in execution.
    ///
    private var timeExecuting: TimeInterval = 0
    
    /// The set of targets that were hit by the attack.
    ///
    private var targetsHit: Set<String>
    
    /// The flag stating whether the attack being executed is unavoidable.
    ///
    private var unavoidable = false
    
    /// The private backing for the `isExecuting` getter.
    ///
    private var _isExecuting = false
    
    /// Indicates whether or not the attack is being executed.
    ///
    var isExecuting: Bool {
        return _isExecuting
    }
    
    /// The physics shape that defines where the attack originates.
    ///
    var referenceShape: PhysicsShape
    
    /// The attack to execute.
    ///
    /// - Note: If an attack is being executed when this property is set, `finishAttack()`
    ///   will be called to end the current execution.
    ///
    var attack: Attack? {
        willSet {
            if isExecuting { finishAttack() }
        }
    }
    
    /// Creates a new instance for the given interaction and delegate values.
    ///
    /// - Parameters:
    ///   - interaction: The `Interaction` instance that defines which targets should be hit.
    ///   - referenceShape: The `PhysicsShape` that defines where the attack originates.
    ///   - attack: An optional `Attack` instance to set on creation. The default value is `nil`.
    ///
    init(interaction: Interaction, referenceShape: PhysicsShape, attack: Attack? = nil) {
        self.interaction = interaction
        self.referenceShape = referenceShape
        self.attack = attack
        node = SKNode()
        targetsHit = []
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Executes the attack.
    ///
    /// This method will fail if the attack is already being executed.
    ///
    /// - Parameter unavoidable: The flag stating whether the attack is unavoidable.
    ///   The default value is `false`.
    /// - Returns: `true` if the attack could be set in execution, `false` otherwise.
    ///
    @discardableResult
    func executeAttack(unavoidable: Bool = false) -> Bool {
        guard !isExecuting, let attack = attack else { return false }
        
        node.name = "Attack." + attack.identifier
        ContactNotifier.registerCallbackFor(nodeNamed: node.name!, callback: self)
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: attack.broadness, height: attack.reach))
        node.position = CGPoint.zero
        node.zRotation = 0
        let direction = directionComponent.direction
        
        // Set the position and rotation of the attack node based on the entity's facing direction
        switch direction {
        case .north:
            switch referenceShape {
            case .circle(let radius, let center):
                node.position = CGPoint(x: center.x, y: center.y + radius + attack.reach / 2.0)
            case .rectangle(let size, let center):
                node.position = CGPoint(x: center.x, y: center.y + size.height / 2.0 + attack.reach / 2.0)
            }
        case .south:
            switch referenceShape {
            case .circle(let radius, let center):
                node.position = CGPoint(x: center.x, y: center.y - radius - attack.reach / 2.0)
            case .rectangle(let size, let center):
                node.position = CGPoint(x: center.x, y: center.y - size.height / 2.0 - attack.reach / 2.0)
            }
        case .east:
            node.zRotation = CGFloat.pi / 2.0
            switch referenceShape {
            case .circle(let radius, let center):
                node.position = CGPoint(x: center.x + radius + attack.reach / 2.0, y: center.y)
            case .rectangle(let size, let center):
                node.position = CGPoint(x: center.x + size.width / 2.0 + attack.reach / 2.0, y: center.y)
            }
        case .west:
            node.zRotation = CGFloat.pi / 2.0
            switch referenceShape {
            case .circle(let radius, let center):
                node.position = CGPoint(x: center.x - radius - attack.reach / 2.0, y: center.y)
            case .rectangle(let size, let center):
                node.position = CGPoint(x: center.x - size.width / 2.0 - attack.reach / 2.0, y: center.y)
            }
        }
        
        let xRange = SKRange(constantValue: node.position.x)
        let yRange = SKRange(constantValue: node.position.y)
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = nodeComponent.node
        node.constraints = [constraint]
        
        self.unavoidable = unavoidable
        _isExecuting = true
        return true
    }
    
    /// Finishes the attack, removing its node and resetting the control properties.
    ///
    /// This method is called automatically by `update(deltaTime:)` when an execution reaches its duration,
    /// and it can also be used to end the attack early.
    ///
    func finishAttack() {
        if let name = node.name {
            ContactNotifier.removeCallbackFor(nodeNamed: name, callback: self)
        }
        node.removeFromParent()
        node.constraints = nil
        targetsHit = []
        _isExecuting = false
        timeExecuting = 0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard isExecuting else { return }
        
        timeExecuting += seconds
        if timeExecuting >= (attack!.delay + attack!.duration + attack!.conclusion) {
            finishAttack()
        } else if node.physicsBody != nil && timeExecuting >= (attack!.delay + attack!.duration) {
            node.physicsBody = nil
        } else if node.parent == nil && timeExecuting >= attack!.delay {
            nodeComponent.node.addChild(node)
            attack!.sfx?.play(at: nodeComponent.node.position, sceneKind: .level)
        }
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard let target = contact.otherBody.node?.entity as? Entity, let attack = attack else { return }
        
        guard targetsHit.insert(target.identifier).inserted else { return }
        
        Combat.carryOutHostileAction(using: attack.medium, on: target, as: entity as? Entity,
                                     damage: attack.damage, conditions: attack.conditions,
                                     unavoidable: unavoidable)
    }
    
    func contactDidEnd(_ contact: Contact) {
        
    }
    
    override func didAddToEntity() {
        node.entity = entity
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
    }
    
    deinit {
        node.removeFromParent()
        node.constraints = nil
    }
}
