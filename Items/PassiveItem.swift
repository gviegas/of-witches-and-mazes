//
//  PassiveItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that applies a passive effect when equipped.
///
protocol PassiveItem: Item {
    
    /// Informs that an entity has equipped the item.
    ///
    /// - Parameter entity: The entity that equipped the item.
    ///
    func didEquip(onEntity entity: Entity)
    
    /// Informs that an entity has unequipped the item.
    ///
    /// - Parameter entity: The entity that unequipped the item.
    ///
    func didUnequip(onEntity entity: Entity)
}
