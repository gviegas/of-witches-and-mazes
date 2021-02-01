//
//  DescribableItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/30/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that provides a textual description of itself.
///
protocol DescribableItem: Item {
    
    /// Creates a textual description of the item.
    ///
    /// - Parameter entity: The entity that the item refers to.
    /// - Returns: A `string` describing the item.
    ///
    func descriptionFor(entity: Entity) -> String
}
