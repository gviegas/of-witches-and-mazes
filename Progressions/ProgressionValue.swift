//
//  ProgressionValue.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that defines a progression's initial value and its associated increment rate
/// for each level.
///
struct ProgressionValue {
    
    /// The progression value where initial value and rate are both zero.
    ///
    static let zero = ProgressionValue(initialValue: 0, rate: 0)
    
    /// The initial (base) value.
    ///
    let initialValue: Int
    
    /// The rate associated with the value.
    ///
    let rate: Double
    
    /// Computes the value for a given level.
    ///
    /// - Parameter level: The level to compute the value for.
    /// - Returns: The value for the given level.
    ///
    func forLevel(_ level: Int) -> Int {
        assert(level > 0)
        
        let bonus = Double(level - 1) * rate
        return initialValue + Int(bonus.rounded())
    }
}
