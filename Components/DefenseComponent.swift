//
//  DefenseComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

/// A component that provides an entity with a defense value to defend itself against attacks.
///
class DefenseComponent: Component {
    
    /// The private backing for the `defense` property.
    ///
    private var _defense = 0.0
    
    /// The defense bounds.
    ///
    let bounds = 0.0...0.9
    
    /// The defense value.
    ///
    var defense: Double {
        return max(bounds.lowerBound, min(bounds.upperBound, _defense))
    }
    
    /// Modifies the defense value.
    ///
    /// - Parameter value: The defense value to add to the current one.
    ///
    func modifyDefense(by value: Double) {
        _defense += value
    }
    
    /// Attempts to defend.
    ///
    /// - Returns: `true` if the defense was successful, `false` otherwise.
    ///
    func defend() -> Bool {
        return Double.random(in: 0.0...1.0) < defense
    }
}
