//
//  HealingItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines an `Item` type that has a `Healing` property.
///
protocol HealingItem: Item {
    
    /// The `Healing`.
    ///
    var healing: Healing { get }
}
