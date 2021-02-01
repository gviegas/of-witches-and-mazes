//
//  DamageAdjustmentComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/17/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

/// A component that provides an entity with modifiers to apply on damage caused/taken.
///
/// The formulae used to adjust a given `amount` of damage are:
///
///     amount + (amount * damageCaused)
///     amount + (amount * damageTaken)
///
/// This allows for negative values to decrease damage. For example, setting the following values:
///
///     damageCaused = -0.3
///     damageTaken = 1.0
///
/// Will decrease the amount of damage caused by 30% and will double the amount of damage taken.
///
/// - Note: Although adjustments can be set to values outside the predefined `-1.0...2.0` range,
///   they will be clamped when using the class methods to retrieve them and/or apply damage
///   adjustment. This allows for different sources to mutate this values and then redo the
///   modifications without worrying about clamped values.
///
class DamageAdjustmentComponent: Component {
    
    /// The adjustment applied to damage caused of a specific `DamageType`. This valued is summed
    /// to `damageCaused` when computing the final adjustment for a given type of damage.
    ///
    private var damageCausedByType: [DamageType: Double] = [:]
    
    /// The adjustment applied to damage taken of a specific `DamageType`. This valued is summed
    /// to `damageTaken` when computing the final adjustment for a given type of damage.
    ///
    private var damageTakenByType: [DamageType: Double] = [:]
    
    /// The adjustment applied to damage caused.
    ///
    private var damageCaused = 0.0
    
    /// The adjustment applied to damage taken.
    ///
    private var damageTaken = 0.0
    
    /// The adjustments bounds.
    ///
    let bounds = -1.0...2.0
    
    /// Computes the base damage caused adjustment.
    ///
    /// - Returns: The base damage caused, in the range `-1.0...2.0`.
    ///
    func baseDamageCaused() -> Double {
        return max(bounds.lowerBound, min(bounds.upperBound, damageCaused))
    }
    
    /// Computes the base damage taken adjustment.
    ///
    /// - Returns: The base damage taken, in the range `-1.0...2.0`.
    ///
    func baseDamageTaken() -> Double {
        return max(bounds.lowerBound, min(bounds.upperBound, damageTaken))
    }
    
    /// Computes the damage caused adjustment for a specific `DamageType`.
    ///
    /// - Parameters:
    ///   - type: The type of damage.
    ///   - ignoreBaseDamage: A flag stating whether or not the base damage adjustment should be
    ///     ignored and compute only the adjustment associated with the `type`. The default
    ///     value is `false`.
    /// - Returns: The damage caused for the given type of damage.
    ///
    func damageCausedFor(type: DamageType, ignoreBaseDamage: Bool = false) -> Double {
        let typeDamage = max(bounds.lowerBound, min(bounds.upperBound, damageCausedByType[type] ?? 0))
        if ignoreBaseDamage { return typeDamage }
        
        let baseDamage = baseDamageCaused()
        return max(bounds.lowerBound, min(bounds.upperBound, baseDamage + typeDamage))
    }
    
    /// Computes the damage taken adjustment for a specific `DamageType`.
    ///
    /// - Parameters:
    ///   - type: The type of damage.
    ///   - ignoreBaseDamage: A flag stating whether or not the base damage adjustment should be
    ///     ignored and compute only the adjustment associated with the `type`. The default
    ///     value is `false`.
    /// - Returns: The damage taken for the given type of damage.
    ///
    func damageTakenFor(type: DamageType, ignoreBaseDamage: Bool = false) -> Double {
        let typeDamage = max(bounds.lowerBound, min(bounds.upperBound, damageTakenByType[type] ?? 0))
        if ignoreBaseDamage { return typeDamage }
        
        let baseDamage = baseDamageTaken()
        return max(bounds.lowerBound, min(bounds.upperBound, baseDamage + typeDamage))
    }
    
    /// Modifies the base damage caused adjustment.
    ///
    /// - Parameter adjustment: An amount to be summed to the current one.
    //
    func modifyDamageCaused(by adjustment: Double) {
        damageCaused += adjustment
    }
    
    /// Modifies the base damage taken adjustment.
    ///
    /// - Parameter adjustment: An amount to be summed to the current one.
    //
    func modifyDamageTaken(by adjustment: Double) {
        damageTaken += adjustment
    }
    
    /// Modifies the damage caused adjustment for a specific `DamageType`.
    ///
    /// - Parameters:
    ///   - type: The damage type.
    ///   - adjustment: An amount to be summed to the current one.
    ///
    func modifyDamageCausedFor(type: DamageType, by adjustment: Double) {
        let newAdjustment: Double
        if let currentAdjustment = damageCausedByType[type] {
            newAdjustment = currentAdjustment + adjustment
        } else {
            newAdjustment = adjustment
        }
        damageCausedByType[type] = newAdjustment
    }
    
    /// Modifies the damage taken adjustment for a specific `DamageType`.
    ///
    /// - Parameters:
    ///   - type: The damage type.
    ///   - adjustment: An amount to be summed to the current one.
    ///
    func modifyDamageTakenFor(type: DamageType, by adjustment: Double) {
        let newAdjustment: Double
        if let currentAdjustment = damageTakenByType[type] {
            newAdjustment = currentAdjustment + adjustment
        } else {
            newAdjustment = adjustment
        }
        damageTakenByType[type] = newAdjustment
    }
    
    /// Applies damage caused adjustment to a given amount of damage.
    ///
    /// - Parameters:
    ///   - damage: The amount of damage to be modified.
    ///   - type: An optional `DamageType` that identifies the type of damage.
    /// - Returns: The new amount of damage.
    ///
    func applyDamageCausedAdjustmentTo(damage: Int, type: DamageType?) -> Int {
        let adjustment = type != nil ? damageCausedFor(type: type!) : baseDamageCaused()
        return max(0, damage + Int((Double(damage) * adjustment).rounded()))
    }
    
    /// Applies damage taken adjustment to a given amount of damage.
    ///
    /// - Parameters:
    ///   - damage: The amount of damage to be modified.
    ///   - type: An optional `DamageType` that identifies the type of damage.
    /// - Returns: The new amount of damage.
    ///
    func applyDamageTakenAdjustmentTo(damage: Int, type: DamageType?) -> Int {
        let adjustment = type != nil ? damageTakenFor(type: type!) : baseDamageTaken()
        return max(0, damage + Int((Double(damage) * adjustment).rounded()))
    }
    
    /// Checks if damage caused is already capped towards its lower bound (i.e., it cannot be
    /// decreased any further).
    ///
    /// - Parameter type: An optional damage type to check. If `nil`, the base damage caused is
    ///   checked instead.
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isDamageCausedLowerCapped(for type: DamageType?) -> Bool {
        if let type = type {
            return (damageCausedByType[type] ?? 0) <= bounds.lowerBound
        }
        return damageCaused <= bounds.lowerBound
    }
    
    /// Checks if damage taken is already capped towards its lower bound (i.e., it cannot be
    /// decreased any further).
    ///
    /// - Parameter type: An optional damage type to check. If `nil`, the base damage taken is
    ///   checked instead.
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isDamageTakenLowerCapped(for type: DamageType?) -> Bool {
        if let type = type {
            return (damageTakenByType[type] ?? 0) <= bounds.lowerBound
        }
        return damageTaken <= bounds.lowerBound
    }
    
    /// Checks if damage caused is already capped towards its upper bound (i.e., it cannot be
    /// increased any further).
    ///
    /// - Parameter type: An optional damage type to check. If `nil`, the base damage caused is
    ///   checked instead.
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isDamageCausedUpperCapped(for type: DamageType?) -> Bool {
        if let type = type {
            return (damageCausedByType[type] ?? 0) >= bounds.upperBound
        }
        return damageCaused >= bounds.upperBound
    }
    
    /// Checks if damage taken is already capped towards its upper bound (i.e., it cannot be
    /// increased any further).
    ///
    /// - Parameter type: An optional damage type to check. If `nil`, the base damage taken is
    ///   checked instead.
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isDamageTakenUpperCapped(for type: DamageType?) -> Bool {
        if let type = type {
            return (damageTakenByType[type] ?? 0) >= bounds.upperBound
        }
        return damageTaken >= bounds.upperBound
    }
}
