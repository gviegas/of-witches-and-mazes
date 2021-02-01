//
//  Healing.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum defining the form of healing.
///
enum HealingForm {
    
    /// The absolute amount of health points for the healing.
    ///
    case absolute(ClosedRange<Int>)
    
    /// The percentage of health points for the healing, between `0` (nothing) and `1.0` (all).
    ///
    case percentage(ClosedRange<Double>)
}

/// A class that defines the healing, used by instances that can restore health points
/// of entities.
///
class Healing {
    
    /// The base amount of health points restored.
    ///
    let baseHealing: HealingForm
    
    /// The healing modifiers from the abilities of an entity's `AbilityComponent`.
    ///
    /// This tuple must hold values between 0 and 1.0, which will be interpreted as the amount
    /// contributed by each ability to the final healing.
    /// This property is always `nil` for percentage-based healing.
    ///
    let modifiers: [Ability: Double]?
    
    /// The optional sound effect to play when healing.
    ///
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - scale: The value used to scale up the healing to its level.
    ///   - ratio: The ratio between the minimum and maximum healing, used to create the base healing range.
    ///   - modifiers: A dictionary containing values between 0 and 1.0, to be interpreted as healing bonuses
    ///     from each ability.
    ///   - level: The level to which the healing should be scaled up.
    ///   - sfx: An optional sound effect to play when healing.
    ///
    init(scale: Double, ratio: Double, level: Int, modifiers: [Ability: Double], sfx: SoundFX?) {
        assert(scale > 0)
        assert((0...1.0).contains(ratio))
        
        // Create the base healing range from the scale, ratio and level values
        let average = scale * Double(level)
        let deviation = average * ratio
        let lowerBound = max(1, Int((average - deviation).rounded()))
        let upperBound = max(lowerBound + 1, Int((average + deviation).rounded()))
        self.baseHealing = .absolute(lowerBound...upperBound)
        
        self.modifiers = modifiers
        self.sfx = sfx
    }
    
    /// Creates a new instance from the given percentage range.
    ///
    /// - Parameters:
    ///   - percentage: A range defining the percentage of healing, between 0 and 1.0.
    ///   - sfx: An optional sound effect to play when healing.
    ///
    init(percentage: ClosedRange<Double>, sfx: SoundFX?) {
        assert(percentage.lowerBound >= 0 && percentage.upperBound <= 1.0001)
        self.baseHealing = .percentage(percentage)
        self.sfx = sfx
        modifiers = nil
    }
    
    /// Restores an entity's health points.
    ///
    /// - Parameters:
    ///   - target: The target entity to be healed.
    ///   - source: An optional entity as the source of the healing.
    /// - Returns: The amount of healing applied.
    ///
    @discardableResult
    func heal(target: Entity, source: Entity?) -> Int {
        guard let healthComponent = target.component(ofType: HealthComponent.self) else { return 0 }
        
        let healing: Int
        switch baseHealing {
        case .absolute(let range):
            if let abilityComponent = source?.component(ofType: AbilityComponent.self) {
                let bonus = modifiers!.reduce(0.0) { result, modifier in
                    result + Double(abilityComponent.totalValue(of: modifier.key)) * modifier.value
                }
                healing = Int.random(in: range) + Int(bonus.rounded())
            } else {
                healing = Int.random(in: range)
            }
        case .percentage(let range):
            let hp = max(0, healthComponent.totalHp - healthComponent.temporaryHP)
            healing = Int((Double.random(in: range) * Double(hp)).rounded())
        }
        
        let restored = healthComponent.restoreHP(healing)
        if let sfx = sfx, let position = target.component(ofType: NodeComponent.self)?.node.position {
            sfx.play(at: position, sceneKind: .level)
        }
        target.component(ofType: LogComponent.self)?.writeEntry(content: "\(restored)", style: .healing)
        return restored
    }
}
