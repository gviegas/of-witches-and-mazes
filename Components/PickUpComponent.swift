//
//  PickUpComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/12/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that defines the kinds of pickable objects.
///
enum PickUpKind {
    
    /// `Item` objects, represented by two lists of `(name: String, icon: Icon, count: Int)` tuples.
    /// The first item list, `stored`, holds the items that were successfully added to the entity's
    /// `InventoryComponent`. The second item list, `left`, holds the items that could not be added.
    ///
    case items(stored: [(name: String, icon: Icon, count: Int)],
        left: [(name: String, icon: Icon, count: Int)])
}

/// A protocol that defines the pick up delegate, called by the `PickUpComponent` when it
/// attempts to pick something up.
///
protocol PickUpDelegate: AnyObject {
    
    /// Informs the delegate that objects were picked up.
    ///
    /// - Parameter kind: The `PickUpKind` that holds information about picked up objects.
    ///
    func didPickUp(kind: PickUpKind)
}

/// A component that enables an entity to pick up objects.
///
class PickUpComponent: Component, Contactable {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a PickUpComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var inventoryComponent: InventoryComponent {
        guard let component = entity?.component(ofType: InventoryComponent.self) else {
            fatalError("An entity with a PickUpComponent must also have an InventoryComponent")
        }
        return component
    }
    
    /// The time to wait before checking a contacting entity on update.
    ///
    private static let waitTime: TimeInterval = 1.0
    
    /// The pick up node.
    ///
    private let node: SKNode
    
    /// The flag stating whether to present an alert the next time a pick up attempt fails.
    ///
    private var mustAlert: Bool
    
    /// The elapsed time since last checking a contacting entity on update.
    ///
    private var elapsedTime: TimeInterval
    
    /// The list of loot nodes that are in contact with the pick up system and must be
    /// checked on update.
    ///
    private var inContact: [String: LootNode] {
        didSet {
            if inContact.isEmpty { mustAlert = true }
        }
    }
    
    /// The pick up delegate, called when picking up.
    ///
    weak var delegate: PickUpDelegate?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: An `Interaction` type defining the pickable objects.
    ///   - radius: The pick up radius.
    ///   - delegate: An optional `PickUpDelegate` to be called when picking up.
    ///
    init(interaction: Interaction, radius: CGFloat, delegate: PickUpDelegate?) {
        node = SKNode()
        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        interaction.updateInteractions(onPhysicsBody: physicsBody)
        node.physicsBody = physicsBody
        mustAlert = true
        elapsedTime = 0
        inContact = [:]
        self.delegate = delegate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the pick up node to the entity's node.
    ///
    /// If the pick up node is already attached, this method has no effect.
    ///
    func attach() {
        if node.parent == nil, let entity = entity {
            let id = (entity as? Entity)?.identifier ?? "\(ObjectIdentifier(entity))"
            node.name = "PickUpComponent." + id
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
    
    /// Detaches the pick up node from the entity's node.
    ///
    /// If the pick up node is not attached, this method has no effect.
    ///
    func detach() {
        if let _ = node.parent {
            ContactNotifier.removeCallbackFor(nodeNamed: node.name!, callback: self)
            node.removeFromParent()
            node.constraints = nil
        }
    }
    
    /// Attempts to loot items from the given `LootNode` instance.
    ///
    /// - Parameter target: The `LootNode` instance to attempt looting.
    ///
    private func lootItems(of target: LootNode) {
        var stored = [String: (name: String, icon: Icon, count: Int)]()
        var left = [String: (name: String, icon: Icon, count: Int)]()
        
        // Try to add the loot items to the inventory
        for item in target.droppedItems {
            let stackCount = (item as? StackableItem)?.stack.count
            let added = inventoryComponent.addItem(item)
            switch added {
            case 0:
                if let _ = left[item.name] {
                    left[item.name]!.count += (item as? StackableItem)?.stack.count ?? 1
                } else {
                    left[item.name] = (item.name, item.icon, (item as? StackableItem)?.stack.count ?? 1)
                }
            case 1 where !(item is StackableItem):
                if let _ = stored[item.name] {
                    stored[item.name]!.count += 1
                } else {
                    stored[item.name] = (item.name, item.icon, 1)
                }
                target.droppedItems.remove(at: target.droppedItems.firstIndex { $0 === item }!)
            default:
                if let _ = stored[item.name] {
                    stored[item.name]!.count += added
                } else {
                    stored[item.name] = (item.name, item.icon, added)
                }
                if stackCount! != added {
                    if let _ = left[item.name] {
                        left[item.name]!.count += stackCount! - added
                    } else {
                        left[item.name] = (item.name, item.icon, stackCount! - added)
                    }
                } else {
                    target.droppedItems.remove(at: target.droppedItems.firstIndex { $0 === item }!)
                }
            }
        }
        
        if left.isEmpty {
            inContact[target.identifier] = nil
            target.removeFromParent()
        } else {
            inContact[target.identifier] = target
            elapsedTime = 0
        }
        
        if !stored.isEmpty { target.playSoundEffect() }
        
        let kind = PickUpKind.items(stored: Array(stored.values), left: Array(left.values))
        showPickUpInfo(kind: kind)
        delegate?.didPickUp(kind: kind)
    }
    
    /// Shows in the UI the outcome of a pick up action.
    ///
    /// - Parameter kind: The `PickUpKind` that holds information about picked up objects.
    ///
    private func showPickUpInfo(kind: PickUpKind) {
        switch kind {
        case .items(let stored, let left):
            if !stored.isEmpty {
                let entries = stored.map {
                    ($0.icon, $0.name, $0.count > 1 ? String($0.count) : nil)
                }
                if let scene = SceneManager.levelScene {
                    entries.forEach {
                        let overlay = PickUpOverlay(rect: scene.frame, icon: $0.0, text: $0.1, iconText: $0.2)
                        scene.enqueuePickUp(overlay)
                    }
                }
            }
            if !left.isEmpty && mustAlert {
                if let scene = SceneManager.levelScene {
                    let note = NoteOverlay(rect: scene.frame, text: "Inventory is full")
                    scene.presentNote(note)
                    mustAlert = false
                }
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard !inContact.isEmpty else { return }
        
        elapsedTime += seconds
        
        if elapsedTime >= PickUpComponent.waitTime {
            elapsedTime = 0
            for (_, entity) in inContact {
                lootItems(of: entity)
            }
        }
    }
    
    func contactDidBegin(_ contact: Contact) {
        guard let target = contact.otherBody.node as? LootNode else { return }
        lootItems(of: target)
    }
    
    func contactDidEnd(_ contact: Contact) {
        guard let target = contact.otherBody.node as? LootNode else { return }
        inContact[target.identifier] = nil
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
