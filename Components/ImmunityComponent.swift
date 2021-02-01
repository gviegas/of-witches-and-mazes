//
//  ImmunityComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum defining the immunity types.
///
enum ImmunityType: Hashable {
    case poison, curse, weakness, hampering, quelling, damage(DamageType)
    
    /// Checks if the given named immunity corresponds to a given condition class type.
    ///
    /// - Parameter conditionClass: The class of the condition to check.
    /// - Returns: `true` is the named immunity corresponds to the condition type, `false` otherwise.
    ///
    func correspondsToCondition(ofClass conditionClass: Condition.Type) -> Bool {
        let flag: Bool
        switch self {
        case .poison:
            flag = conditionClass is PoisonCondition.Type
        case .curse:
            flag = conditionClass is CurseCondition.Type
        case .weakness:
            flag = conditionClass is WeakenCondition.Type
        case .hampering:
            flag = conditionClass is HamperCondition.Type
        case .quelling:
            flag = conditionClass is QuellCondition.Type
        case .damage:
            flag = false
        }
        return flag
    }
}

/// A component that enables an entity to be immune to condition types.
///
class ImmunityComponent: Component {
    
    /// The set defining the entity's immunities.
    ///
    /// - Note: This property is unmanaged, thus every instance that mutates it must keep track of
    ///   changes that may have been applied by others.
    ///
    var immunities: Set<ImmunityType> {
        didSet { broadcast() }
    }
    
    /// Creates a new instance from the given immmunity set.
    ///
    /// - Parameter immunities: The set containing the entity's immunities. The default value is an empty set.
    ///
    init(immunities: Set<ImmunityType> = []) {
        self.immunities = immunities
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Checks if the entity's immunities grant protection against the given `Condition`.
    ///
    /// - Parameter condition: The condition to check for immunity.
    /// - Returns: `true` if the entity should not be affected by the given condition, `false` otherwise.
    ///
    func isImmuneTo(condition: Condition) -> Bool {
        for immunity in immunities {
            if immunity.correspondsToCondition(ofClass: type(of: condition)) { return true }
        }
        return false
    }
    
    /// Checks if the entity's immunities grant protection against the given `DamageType`.
    ///
    /// - Parameter damageType: The damage type to check for immunity.
    /// - Returns: `true` if the entity should not be damaged by the given damage type, `false` otherwise.
    ///
    func isImmuneTo(damageType: DamageType) -> Bool {
        return immunities.contains(.damage(damageType))
    }
}
