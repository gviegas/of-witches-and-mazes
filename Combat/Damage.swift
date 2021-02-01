//
//  Damage.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/2/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that defines the damage types.
///
enum DamageType: String, Comparable {
    case physical = "Physical"
    case magical = "Magical"
    case spiritual = "Spiritual"
    case natural = "Natural"
    
    static func < (lhs: DamageType, rhs: DamageType) -> Bool {
        let order: [DamageType: Int] = [.physical: 1, .magical: 2, .spiritual: 3, .natural: 4]
        return order[lhs]! < order[rhs]!
    }
}

/// A class that defines the damage, used by instances that can cause damage to entities.
///
class Damage {
    
    /// A struct that stores a snapshot of an entity's damage.
    ///
    private struct DamageSnapshot {
        
        /// The damage to inflict.
        ///
        let damage: Int
        
        /// The flag stating whether or not it is a critical hit.
        ///
        let isCritical: Bool
    }
    
    /// The current snapshot.
    ///
    private var snapshot: DamageSnapshot?
    
    /// The base amount of damage, scaled up to the damage's level.
    ///
    let baseDamage: ClosedRange<Int>
    
    /// The damage modifiers from the abilities of an entity's `AbilityComponent`.
    ///
    /// This tuple must hold values between 0 and 1.0, which will be interpreted as the amount
    /// contributed by each ability to the final damage.
    ///
    let modifiers: [Ability: Double]
    
    /// The damage type.
    ///
    let type: DamageType
    
    /// The optional sound effect to play when the damage is applied.
    ///
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - scale: The value used to scale up the damage to its level.
    ///   - ratio: The ratio between the minimum and maximum damage, used to create the base damage range.
    ///   - level: The level to which the damage should be scaled up.
    ///   - modifiers: A dictionary containing values between 0 and 1.0, to be interpreted as
    ///     damage bonuses from each ability.
    ///   - type: The damage type.
    ///   - sfx: An optional sound effect to play when causing damage.
    ///
    init(scale: Double, ratio: Double, level: Int, modifiers: [Ability: Double], type: DamageType, sfx: SoundFX?) {
        assert(scale > 0)
        assert((0...1.0).contains(ratio))
        assert(modifiers.allSatisfy { (0...1.0).contains($1) })
        
        self.modifiers = modifiers
        self.type = type
        self.sfx = sfx
        
        // Create the base damage range from the scale, ratio and level values
        let average = scale * Double(level)
        let deviation = average * ratio
        let lowerBound = max(1, Int((average - deviation).rounded()))
        let upperBound = max(lowerBound + 1, Int((average + deviation).rounded()))
        self.baseDamage = lowerBound...upperBound
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - baseDamage: The range defining the base damage.
    ///   - modifiers: A dictionary containing values between 0 and 1.0, to be interpreted as
    ///     damage bonuses from each ability.
    ///   - type: The damage type.
    ///   - sfx: An optional sound effect to play when causing damage.
    ///
    init(baseDamage: ClosedRange<Int>, modifiers: [Ability: Double], type: DamageType, sfx: SoundFX?) {
        assert(modifiers.allSatisfy { (0...1.0).contains($1) })
        
        self.baseDamage = baseDamage
        self.modifiers = modifiers
        self.type = type
        self.sfx = sfx
    }
    
    /// Creates a snapshot of an entity's damaging modifiers.
    ///
    /// - Parameters:
    ///   - entity: The entity whose modifiers will be used to create the snapshot.
    ///   - medium: The damage's medium.
    /// - Returns: The new `DamageSnapshot` instance.
    ///
    private func newDamageSnapshot(from entity: Entity, using medium: Medium) -> DamageSnapshot {
        var isCritical = false
        
        // Randomly chose an absolute value from the base damage range plus ability modifiers
        var damage = Int.random(in: baseDamage)
        if let abilityComponent = entity.component(ofType: AbilityComponent.self) {
            let bonus = modifiers.reduce(0.0) { result, modifier in
                result + Double(abilityComponent.totalValue(of: modifier.key)) * modifier.value
            }
            damage += Int(bonus.rounded())
        }
        // Apply damage modifiers
        if let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self) {
            damage = damageAdjustmentComponent.applyDamageCausedAdjustmentTo(damage: damage, type: type)
        }
        // Apply critical hit modifiers
        if let criticalHitComponent = entity.component(ofType: CriticalHitComponent.self) {
            let critical = criticalHitComponent.applyCriticalTo(damage: damage, through: medium)
            isCritical = critical.isCritical
            damage = critical.damage
        }
        
        return DamageSnapshot(damage: damage, isCritical: isCritical)
    }
    
    /// Creates a snapshot of an entity's damaging modifiers.
    ///
    /// - Parameters:
    ///   - entity: The entity whose modifiers will be used to create the snapshot.
    ///   - medium: The damage's medium.
    ///
    func createDamageSnapshot(from entity: Entity, using medium: Medium) {
        snapshot = newDamageSnapshot(from: entity, using: medium)
    }
    
    /// Destroys the current damage snapshot.
    ///
    /// If no snapshot was previously created, this method has no effect.
    ///
    func destroyDamageSnapshot() {
        snapshot = nil
    }
    
    /// Causes damage to an entity.
    ///
    /// This method chooses a random value from its computed damage range and then applies this damage
    /// through the target's `HealthComponent`.
    ///
    /// - Note: If `source` is `nil` and there is a stored damage snapshot created using the
    ///  `createDamageSnapshot(from:)` method, it will be used.
    ///
    /// - Parameters:
    ///   - medium: The medium that will cause the damage.
    ///   - target: The target entity to be damaged.
    ///   - source: An optional entity as the source of the damage. If set to `nil`, the method will
    ///     attempt to use the stored damage snapshot.
    /// - Returns: The amount of damage caused.
    ///
    @discardableResult
    func inflict(using medium: Medium, on target: Entity, from source: Entity?) -> Int {
        guard target != source,
            let targetNode = target.component(ofType: NodeComponent.self)?.node,
            let healthComponent = target.component(ofType: HealthComponent.self)
            else { return  0 }
        
        // Check if the target entity is immune to this damage's DamageType
        guard target.component(ofType: ImmunityComponent.self)?.isImmuneTo(damageType: type) != true else {
            target.component(ofType: LogComponent.self)?.writeEntry(content: "Immune", style: .emphasis)
            return 0
        }
        
        var damage: Int
        var isCritical = false
        var fullyAbsorbed = false
        
        // Attempt to apply source/snapshot modifiers
        if let source = source {
            let snapshot = newDamageSnapshot(from: source, using: medium)
            damage = snapshot.damage
            isCritical = snapshot.isCritical
        } else if let snapshot = snapshot {
            damage = snapshot.damage
            isCritical = snapshot.isCritical
        } else {
            damage = Int.random(in: baseDamage)
            isCritical = false
        }
        
        // Apply source's first strike
        if let firstStrikeComponent = source?.component(ofType: FirstStrikeComponent.self) {
            damage = firstStrikeComponent.applyFirstStrikeTo(damage: damage, against: target)
        }
        
        // Apply source's finishing strike
        if let finishingStrikeComponent = source?.component(ofType: FinishingStrikeComponent.self) {
            damage = finishingStrikeComponent.applyFinishingStrikeTo(damage: damage, against: target)
        }
        
        // Apply target's mitigation
        if let mitigationComponent = target.component(ofType: MitigationComponent.self) {
            let mitigation = mitigationComponent.applyMitigationTo(damage: damage)
            fullyAbsorbed = mitigation.fullyAbsorbed
            damage = mitigation.damage
        }
        
        // Apply target's damage taken adjustment
        if let damageAdjustmentComponent = target.component(ofType: DamageAdjustmentComponent.self) {
            damage = damageAdjustmentComponent.applyDamageTakenAdjustmentTo(damage: damage, type: type)
        }
        
        if damage > 0 {
            // Apply damage
            damage = healthComponent.causeDamage(damage, source: source)
            
            // Apply target's second wind
            target.component(ofType: SecondWindComponent.self)?.apply()
            
            if let source = source, !healthComponent.isDead {
                // Apply source's intimidation
                source.component(ofType: IntimidationComponent.self)?.intimidate(target: target)
                switch medium {
                
                case .melee, .ranged:
                    // Apply source's poison
                    source.component(ofType: PoisonComponent.self)?.applyPoison(to: target)
                default:
                    break
                }
                
                switch type {
                case .magical:
                    // Apply source's enfeeblement
                    source.component(ofType: EnfeeblementComponent.self)?.weaken(target: target)
                default:
                    break
                }
            }
            
            sfx?.play(at: targetNode.position, sceneKind: .level)
            
            if isCritical {
                target.component(ofType: LogComponent.self)?.writeEntry(content: "\(damage)", style: .crit)
            } else {
                target.component(ofType: LogComponent.self)?.writeEntry(content: "\(damage)", style: .damage)
            }
            
        } else if fullyAbsorbed {
            if let source = source, !healthComponent.isDead {
                // Apply target's retribution
                target.component(ofType: RetributionComponent.self)?.punish(target: source)
            }
            
            SoundFXSet.FX.landing.play(at: targetNode.position, sceneKind: .level)
            
            target.component(ofType: LogComponent.self)?.writeEntry(content: "Absorbed", style: .emphasis)
        }
        
        return damage
    }
}
