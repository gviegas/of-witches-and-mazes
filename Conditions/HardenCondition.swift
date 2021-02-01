//
//  HardenCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that reduces all damage taken by an entity.
///
class HardenCondition: Condition {
    
    /// The amount to reduce from damage taken, between `0` and `1.0`.
    ///
    let damageTakenReduction: Double
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - damageTakenReduction: A value between `0` and `1.0` to be added to damage taken.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(damageTakenReduction: Double, isExclusive: Bool, isResettable: Bool, duration: TimeInterval?,
         source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        
        self.damageTakenReduction = damageTakenReduction
        self.isExclusive = isExclusive
        self.isResettable = isResettable
        self.duration = duration
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1,
            let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self),
            !damageAdjustmentComponent.isDamageTakenLowerCapped(for: nil)
            else { return false }
        
        damageAdjustmentComponent.modifyDamageTaken(by: -damageTakenReduction)
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self) else {
            return false
        }
        
        damageAdjustmentComponent.modifyDamageTaken(by: damageTakenReduction)
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
