//
//  CurseCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/20/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `HealthReductionCondition` subclass defining the Curse condition.
///
/// Conditions intended to be treated as curses must be instances of `CurseCondition`.
///
class CurseCondition: HealthReductionCondition {
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - reductionFactor: A value between `0` and `1.0` representing the percentage to reduce from health.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///
    init(reductionFactor: Double, isExclusive: Bool, isResettable: Bool, duration: TimeInterval?,
         source: Entity?) {
        
        super.init(reductionFactor: reductionFactor, isExclusive: isExclusive, isResettable: isResettable,
                   duration: duration, source: source, color: .cursed, sfx: SoundFXSet.FX.curseHit)
    }
}
