//
//  LootComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to drop loot on a `Level` and have loot stolen.
///
class LootComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a LootComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    /// The loot table.
    ///
    var lootTable: LootTable
    
    /// The flag stating whether loot was stolen from the entity.
    ///
    var wasStoleFrom: Bool
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameter lootTable: A `LootTable` type to generate the loot.
    ///
    init(lootTable: LootTable) {
        self.lootTable = lootTable
        wasStoleFrom = false
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Drops loot in the current `Level`, represented by a `LootNode` instance.
    ///
    /// - Note: Every time this method is called, a new loot is generated and added to the level.
    ///
    /// - Returns: `true` if loot was added to the current `Level`, `false` if nothing dropped.
    ///
    func drop() -> Bool {
        guard let level = (entity as? Entity)?.level else { return false }
        
        let droppedItems = lootTable.generateLoot()
        if !droppedItems.isEmpty {
            let loot = LootNode(droppedItems: droppedItems, position: physicsComponent.position)
            level.addNode(loot)
            return true
        }
        return false
    }
    
    /// Loses loot in a steal attempt.
    ///
    /// - Note: Upon losing loot, the `wasStoleFrom` flag is set to `true`, and further calls to
    ///   `lose()` will always return an empty list. Setting the flag to `false` will allow
    ///   the entity to be stole from once again.
    ///
    /// - Returns: A list containig the items it lost, or an empty list if nothing was lost.
    ///
    func lose() -> [Item] {
        guard !wasStoleFrom else { return [] }
        let loot = lootTable.generateLoot()
        wasStoleFrom = !loot.isEmpty
        return loot
    }
}
