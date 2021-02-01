//
//  PoisonCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/20/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DamageOverTimeCondition` subclass defining the Poison condition.
///
/// Conditions intended to be treated as poisons must be instances of `PoisonCondition`.
///
class PoisonCondition: DamageOverTimeCondition {
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - tickTime: The time between successive applications of the condition's tick damage.
    ///   - tickDamage: The damage to inflict each time the condition takes effect.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///
    init(tickTime: TimeInterval, tickDamage: Damage, isExclusive: Bool, isResettable: Bool,
         duration: TimeInterval?, source: Entity?) {
        
        super.init(tickTime: tickTime, tickDamage: tickDamage, isExclusive: isExclusive,
                   isResettable: isResettable, duration: duration, source: source,
                   color: .poisoned, sfx: SoundFXSet.FX.poison)
    }
}
