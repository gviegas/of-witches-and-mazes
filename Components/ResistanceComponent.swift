//
//  ResistanceComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

/// A component that provides an entity with a resistance value to defend itself against spells.
///
class ResistanceComponent: Component {
    
    /// The private backing for the `resistance` property.
    ///
    private var _resistance = 0.0
    
    /// The resistance bounds.
    ///
    let bounds = 0.0...0.9
    
    /// The resistance value.
    ///
    var resistance: Double {
        return max(bounds.lowerBound, min(bounds.upperBound, _resistance))
    }
    
    /// Modifies the resistance value.
    ///
    /// - Parameter value: The resistance value to add to the current one.
    ///
    func modifyResistance(by value: Double) {
        _resistance += value
    }
    
    /// Attempts to resist.
    ///
    /// - Returns: `true` if the resistance was successful, `false` otherwise.
    ///
    func resist() -> Bool {
        return Double.random(in: 0.0...1.0) < resistance
    }
}
