//
//  EntityProgressionValues.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class defining the progression values required to make progression for an entity.
///
class EntityProgressionValues {
    
    /// The progression values for each ability.
    ///
    let abilityValues: [Ability: ProgressionValue]
    
    /// The progression value for health points.
    ///
    let healthPointsValue: ProgressionValue
    
    /// The progression value for skill points.
    ///
    let skillPointsValue: ProgressionValue?
    
    /// The progression values for critical hit chance with each medium.
    ///
    let criticalHitValues: [Medium: ProgressionValue]?
    
    /// The progression values for damage caused with each type of damage.
    ///
    let damageCausedValues: [DamageType: ProgressionValue]?
    
    /// The progression values for damage taken with each type of damage.
    ///
    let damageTakenValues: [DamageType: ProgressionValue]?
    
    /// The progression value for defense.
    ///
    let defenseValue: ProgressionValue?
    
    /// The progression value for resistance.
    ///
    let resistanceValue: ProgressionValue?
    
    /// The progression value for mitigation.
    ///
    let mitigationValue: ProgressionValue?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - abilityValues: The progression values for each ability.
    ///   - healthPointsValue: The progression value for health points.
    ///   - skillPointsValue: The progression value for skill points.
    ///   - criticalHitValues: The progression values for critical hit chance with each medium.
    ///   - damageCausedValues: The progression values for damage caused with each type of damage.
    ///   - damageTakenValues: The progression values for damage taken with each type of damage.
    ///   - defenseValue: The progression value for defense.
    ///   - resistanceValue: The progression value for resistance.
    ///   - mitigationValue: The progression value for mitigation.
    ///
    init(abilityValues: [Ability: ProgressionValue], healthPointsValue: ProgressionValue,
         skillPointsValue: ProgressionValue?, criticalHitValues: [Medium: ProgressionValue]?,
         damageCausedValues: [DamageType: ProgressionValue]?, damageTakenValues: [DamageType: ProgressionValue]?,
         defenseValue: ProgressionValue?, resistanceValue: ProgressionValue?, mitigationValue: ProgressionValue?) {
        
        self.abilityValues = abilityValues
        self.healthPointsValue = healthPointsValue
        self.skillPointsValue = skillPointsValue
        self.criticalHitValues = criticalHitValues
        self.damageCausedValues = damageCausedValues
        self.damageTakenValues = damageTakenValues
        self.defenseValue = defenseValue
        self.resistanceValue = resistanceValue
        self.mitigationValue = mitigationValue
    }
    
    /// Creates a new instance that ignores progression for combat modifiers, intended to be used by
    /// entities that can attain new levels.
    ///
    /// - Parameters:
    ///   - abilityValues: The progression values for each ability.
    ///   - healthPointsValue: The progression value for health points.
    ///   - skillPointsValue: The progression value for skill points.
    ///
    init(abilityValues: [Ability: ProgressionValue], healthPointsValue: ProgressionValue,
         skillPointsValue: ProgressionValue) {
        
        self.abilityValues = abilityValues
        self.healthPointsValue = healthPointsValue
        self.skillPointsValue = skillPointsValue
        self.criticalHitValues = nil
        self.damageCausedValues = nil
        self.damageTakenValues = nil
        self.defenseValue = nil
        self.resistanceValue = nil
        self.mitigationValue = nil
    }
}
