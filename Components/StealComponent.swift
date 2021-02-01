//
//  StealComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to steal items from another.
///
class StealComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a StealComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    private var targetComponent: TargetComponent {
        guard let component = entity?.component(ofType: TargetComponent.self) else {
            fatalError("An entity with a StealComponent must also have a TargetComponent")
        }
        return component
    }
    
    private var inventoryComponent: InventoryComponent {
        guard let component = entity?.component(ofType: InventoryComponent.self) else {
            fatalError("An entity with a StealComponent must also have an InventoryComponent")
        }
        return component
    }
    
    private var stateComponent: StateComponent {
        guard let component = entity?.component(ofType: StateComponent.self) else {
            fatalError("An entity with a StealComponent must also have a StateComponent")
        }
        return component
    }
    
    /// The steal range. Targets further away cannot be stolen from.
    ///
    private let range: CGFloat
    
    /// The chance to be detected when attempting to steal.
    ///
    private let detectionChance: Double
    
    /// The target entity set by `examine()`, used by `steal()`.
    ///
    private weak var targetEntity: Entity?
    
    /// Creates a new instance from the given range and detection chance.
    ///
    /// - Parameters:
    ///   - range: The steal range. Targets further away cannot be stolen from.
    ///   - detectionChance: The chance to be detected when attempting to steal.
    ///
    init(range: CGFloat, detectionChance: Double) {
        assert(range > 0 && (0...1.0).contains(detectionChance))
        self.range = range
        self.detectionChance = detectionChance
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Examines the current target to determine the possibility of stealing.
    ///
    /// This method acts as a preliminary check for a steal action. The `steal()` method must not be
    /// called unless `examine()` returns `true`.
    ///
    /// - Returns: `true` if it is possible to attempt stealing from the current target, `false` otherwise.
    ///
    func examine() -> Bool {
        // Check if a target is selected
        guard let targetEntity = targetComponent.source else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No target selected")
                scene.presentNote(note)
            }
            return false
        }
        
        let origin = physicsComponent.position
        let target = targetComponent.target
        let point = CGPoint(x: target!.x - origin.x, y: target!.y - origin.y)
        let distance = (point.x * point.x + point.y * point.y).squareRoot()
        
        // Check if close enough
        guard distance <= range else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Target is too far away")
                scene.presentNote(note)
            }
            return false
        }
        
        self.targetEntity = targetEntity
        return true
    }
    
    /// Attempts to steal from the current target.
    ///
    /// - Note: If the entity is detected by the target while attempting to steal, the former will
    ///   transition to the stardard state.
    ///
    /// - Returns: `true` if loot could be stolen and added to the entity's inventory, `false` otherwise.
    ///
    func steal() -> Bool {
        defer { targetEntity = nil }
        
        // Check if target can be stole from
        guard let lootComponent = targetEntity?.component(ofType: LootComponent.self),
            !lootComponent.wasStoleFrom else {
                
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Nothing to steal")
                scene.presentNote(note)
            }
            return false
        }
        
        // Attempt detection
        guard Double.random(in: 0...1.0) > detectionChance else {
            if stateComponent.canEnter(stateClass: ProtagonistStandardState.self) {
                entity?.component(ofType: LogComponent.self)?.writeEntry(content: "Detected", style: .emphasis)
                stateComponent.enter(stateClass: ProtagonistStandardState.self)
            } else {
                entity?.component(ofType: LogComponent.self)?.writeEntry(content: "Failed", style: .emphasis)
            }
            return false
        }
        
        let loot = lootComponent.lose()
        
        // Check if could steal
        guard !loot.isEmpty else {
            entity?.component(ofType: LogComponent.self)?.writeEntry(content: "Failed", style: .emphasis)
            return false
        }
        
        // Attempt o add the items to the entity's inventory and create an overlay for each addition
        var overlays = [PickUpOverlay]()
        for item in loot {
            let added = inventoryComponent.addItem(item)
            if added != 0, let frame = SceneManager.levelScene?.frame {
                overlays.append(PickUpOverlay(rect: frame, icon: item.icon, text: item.name,
                                              iconText: added > 1 ? "\(added)" : nil))
            }
        }
        
        // Check if all additions failed
        guard !overlays.isEmpty else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Inventory is full")
                scene.presentNote(note)
            }
            return false
        }
        
        // Enqueue the overlays representing the stolen loot
        if let scene = SceneManager.levelScene {
            overlays.forEach { scene.enqueuePickUp($0) }
        }
        
        return true
    }
}
