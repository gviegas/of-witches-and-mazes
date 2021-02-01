//
//  UsableItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/13/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that can be used by an entity.
///
protocol UsableItem: Item {
    
    /// Informs that an entity has used the item.
    ///
    /// - Parameter entity: The entity that used the item.
    ///
    func didUse(onEntity entity: Entity)
}
