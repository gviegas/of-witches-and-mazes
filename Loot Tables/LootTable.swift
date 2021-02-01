//
//  LootTable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol representing the loot table, a type that can generate loot.
///
protocol LootTable {
    
    /// Generates loot.
    ///
    /// - Returns: The generated loot as a list of `Item` instances.
    ///
    func generateLoot() -> [Item]
}
