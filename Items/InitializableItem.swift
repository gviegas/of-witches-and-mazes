//
//  InitializableItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/18/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that defines an `Item` type that can be initialized.
///
/// This protocol is meant for `Items` that do not conform to any other item protocols where
/// initializers are a requirement (as in `StackableItem` and `LevelItem`).
///
protocol InitializableItem: Item {

    /// Creates a new instance.
    ///
    init()
}
