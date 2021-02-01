//
//  DamageOverTimeItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol tha defines an `Item` type that has a `DamageOverTimeCondition` property.
///
protocol DamageOverTimeItem: Item {
    
    /// The `DamageOverTimeCondition`.
    ///
    var damageOverTime: DamageOverTimeCondition { get }
}
