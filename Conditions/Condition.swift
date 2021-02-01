//
//  Condition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/30/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol defining a condition that can be applied to entities.
///
protocol Condition: AnyObject, Identifiable {
    
    /// The flag stating whether or not the condition is exclusive.
    ///
    /// Conditions that have this property set as `true` cannot have more than one instance
    /// affecting the same entity at once.
    ///
    var isExclusive: Bool { get }
    
    /// The flag stating whether or not the condition is resettable.
    ///
    /// Conditions that have this property set as `true` will have their elapsed time reset to `0`
    /// when `applyEffects(onEntity:applicatioNumber)` is called, regardless of its return value.
    /// This property has no effect on conditions where `duration` is `nil`.
    ///
    var isResettable: Bool { get }
    
    /// The duration of the condition.
    ///
    var duration: TimeInterval? { get }
    
    /// The entity that caused the condition.
    ///
    var source: Entity? { get set }
    
    /// The color animation to use when applying the condition.
    ///
    var color: ColorAnimation? { get }
    
    /// The sound effect to play when the applying the condition.
    ///
    var sfx: SoundFX? { get }
    
    /// The short text to write in the log when applying the condition.
    ///
    var logText: String? { get }
    
    /// Applies the effects of the condition to the given entity.
    ///
    /// - Parameters:
    ///   - entity: The target entity.
    ///   - applicationNumber: The current application number, starting from `1` and increasing
    ///     after each successful application of this method. Conditions that do not wish to
    ///     stack up effects should ignore calls were `applicationNumber` is greater than `1`.
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool
    
    /// Removes the effects of the condition from the given entity.
    ///
    /// - Parameters:
    ///   - entity: The target entity.
    ///   - applications: The number of times that `applyEffects(onEntity:)` was successfully
    ///     executed on the entity. Conditions that can stack up effects should use this value
    ///     to correctly remove multiple applications.
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool
    
    /// Updates the condition effects for a given entity.
    ///
    /// - Parameters:
    ///   - entity: The entity on which the condition must be updated.
    ///   - seconds: The elapsed time since the last update.
    ///
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval)
}

extension Condition {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    var logText: String? {
        switch self {
        case is PoisonCondition:
            return "Poisoned"
        case is CurseCondition:
            return "Cursed"
        default:
            return nil
        }
    }
}
