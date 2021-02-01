//
//  CriticalHitComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/17/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

/// A component that provides an entity with critical hit modifiers.
///
class CriticalHitComponent: Component {
    
    /// The crititcal hit chance applied to damage from a specific `Medium`. This value is summed
    /// to `critChance` when computing the final critical hit chance for a given medium.
    ///
    private var chanceByMedium: [Medium: Double] = [:]
    
    /// The private backing for the `criticalChance` property.
    ///
    private var chance = 0.05
    
    /// The critical chance bounds.
    ///
    let bounds = 0.0...1.0
    
    /// The critical hit chance.
    ///
    var criticalChance: Double {
        return max(bounds.lowerBound, min(bounds.upperBound, chance))
    }
    
    /// Computes the critical hit chance for a specific `Medium`.
    ///
    /// - Parameters:
    ///   - medium: The damage medium.
    ///   - ignoreBaseChance: A flag stating whether or not the base critical hit chance should be
    ///   ignored and compute only the chance associated with the medium. The default value is `false`.
    /// - Returns: The critical hit chance for the given medium.
    ///
    func criticalChanceFor(medium: Medium, ignoreBaseChance: Bool = false) -> Double {
        let mediumChance = max(bounds.lowerBound, min(bounds.upperBound, chanceByMedium[medium] ?? 0))
        return ignoreBaseChance ? mediumChance : criticalChance + mediumChance
    }
    
    /// Modifies the base critical hit chance.
    ///
    /// - Parameter chance: The critical hit chance to add to the current one.
    ///
    func modifyCriticalChance(by chance: Double) {
        self.chance += chance
    }
    
    /// Modifies the critical hit chance for a specific `Medium`.
    ///
    /// - Parameters:
    ///   - medium: The damage medium.
    ///   - chance: The critical hit chance to add to the current one.
    ///
    func modifyCriticalChanceFor(medium: Medium, by chance: Double) {
        let newChance: Double
        if let currentChance = chanceByMedium[medium] {
            newChance = currentChance + chance
        } else {
            newChance = chance
        }
        chanceByMedium[medium] = newChance
    }
    
    /// Applies critical hit chance.
    ///
    /// - Parameters:
    ///   - damage: The amount of damage to be modified.
    ///   - medium: An optional `Medium` that identifies the damage medium.
    /// - Returns: A tuple where the first value states whether or not it was a critical hit, and the
    ///   second value holds the new amount of damage.
    ///
    func applyCriticalTo(damage: Int, through medium: Medium?) -> (isCritical: Bool, damage: Int) {
        let chance: Double
        switch medium {
        case .some(let medium):
            chance = criticalChanceFor(medium: medium)
        case .none:
            chance = criticalChance
        }
        return Double.random(in: 0...1.0) <= chance ? (true, damage * 2) : (false, damage)
    }
}
