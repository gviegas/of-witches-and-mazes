//
//  EntityProgression.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines level progression for entities.
///
class EntityProgression {
    
    /// The range of available levels for any progression.
    ///
    static let levelRange = 1...100
    
    /// The experience factor.
    ///
    static let xpFactor = 150.0
    
    /// The experience exponent.
    ///
    static let xpExponent = 2.1649
    
    /// The experience reward factor.
    ///
    static let rewardFactor = 30.0
    
    /// The experience reward exponent.
    ///
    static let rewardExponent = 0.763
    
    /// Calculates the amount of experience required to attain a given level of experience.
    ///
    /// - Parameter level: The level of experience.
    /// - Returns: The amount of experience required to attain the level.
    ///
    class func requiredXPForLevel(_ level: Int) -> Int {
        if level == levelRange.lowerBound { return 0 }
        return Int((pow(Double(level), xpExponent) * xpFactor).rounded())
    }
    
    /// Sets an entity to a given level of experience.
    ///
    /// - Parameters:
    ///   - level: The level to set, in the range defined by `EntityProgression.levels`.
    ///   - values: The `EntityProgressionValues` instance defining how to make progression.
    ///   - entity: The entity to make progression.
    ///
    class func toLevel(_ level: Int, values: EntityProgressionValues, entity: Entity) {
        assert(levelRange.contains(level))
        
        // Apply progression to abilities
        if let abilityComponent = entity.component(ofType: AbilityComponent.self) {
            for (key, value) in values.abilityValues {
                abilityComponent.setBaseValue(of: key, value: value.forLevel(level))
            }
        }
        
        // Apply progression to health points
        entity.component(ofType: HealthComponent.self)?.baseHP = values.healthPointsValue.forLevel(level)
        
        // Apply progression to skill points
        if let v = values.skillPointsValue {
            entity.component(ofType: SkillComponent.self)?.totalPoints = v.forLevel(level)
        }
        
        // Note: Below are combat modifiers that must never be set for entities that can attain new levels.
        // It is expected that entities that can gain levels will have all the following values set to `nil`.
        
        // Apply progression to critical hit
        if let v = values.criticalHitValues, let component = entity.component(ofType: CriticalHitComponent.self) {
            for (key, value) in v {
                component.modifyCriticalChanceFor(medium: key, by: 0.01 * Double(value.forLevel(level)))
            }
        }
        
        // Apply progression to damage
        if let  component = entity.component(ofType: DamageAdjustmentComponent.self) {
            if let v = values.damageCausedValues {
                for (key, value) in v {
                    component.modifyDamageCausedFor(type: key, by: 0.01 * Double(value.forLevel(level)))
                }
            }
            if let v = values.damageTakenValues {
                for (key, value) in v {
                    component.modifyDamageTakenFor(type: key, by: 0.01 * Double(value.forLevel(level)))
                }
            }
        }
        
        // Apply progression to defense
        if let v = values.defenseValue {
            entity.component(ofType: DefenseComponent.self)?.modifyDefense(by: 0.01 * Double(v.forLevel(level)))
        }
        
        // Apply progression to resistance
        if let v = values.resistanceValue {
            entity.component(ofType: ResistanceComponent.self)?.modifyResistance(by: 0.01 * Double(v.forLevel(level)))
        }
        
        // Apply progression to mitigation
        if let v = values.mitigationValue {
            entity.component(ofType: MitigationComponent.self)?.modifyMitigation(by: v.forLevel(level))
        }
    }
    
    /// Awards experience to an entity.
    ///
    /// - Parameters:
    ///   - entity: The entity to receive the experience reward.
    ///   - rewardLevel: The level of the experience reward.
    ///   - rewardGrade: The grade of the experience reward. The default value is `1.0`, which means
    ///     that the entity will be awarded the exactly reward provided by `rewardLevel`.
    ///
    class func awardXP(to entity: Entity, rewardLevel: Int, rewardGrade: Double = 1.0) {
        guard levelRange.contains(rewardLevel) else { return }
        guard rewardGrade > 0.0 else { return }
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else { return }
        
        let level = rewardLevel
        let grade = rewardGrade
        let reward = Int((pow(Double(level), rewardExponent) * rewardFactor * grade).rounded())
        progressionComponent.gainXP(reward)
    }
    
    /// Awards experience to an entity.
    ///
    /// - Parameters:
    ///   - entity: The entity to receive the experience reward.
    ///   - other: The entity to give the experience reward.
    ///
    class func awardXP(to entity: Entity, from other: Entity) {
        guard let progressionComponent = other.component(ofType: ProgressionComponent.self) else { return }
        
        let level = progressionComponent.levelOfExperience
        let grade = progressionComponent.grade
        return awardXP(to: entity, rewardLevel: level, rewardGrade: grade)
    }
}
