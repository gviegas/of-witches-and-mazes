//
//  DamageOverTimeCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that causes damage over time to an entity.
///
class DamageOverTimeCondition: Condition {

    /// The elapsed time.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The tick count.
    ///
    private var tickCount = 0

    /// The time between ticks.
    ///
    let tickTime: TimeInterval
    
    /// The damage instance.
    ///
    let tickDamage: Damage
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - tickTime: The time between successive applications of the condition's tick damage.
    ///   - tickDamage: The damage to inflict each time the condition takes effect.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(tickTime: TimeInterval, tickDamage: Damage, isExclusive: Bool, isResettable: Bool,
         duration: TimeInterval?, source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        
        self.tickTime = tickTime
        self.tickDamage = tickDamage
        self.isExclusive = isExclusive
        self.isResettable = isResettable
        self.duration = duration
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1 else { return false }
        elapsedTime = 0
        tickCount = 0
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if Int(elapsedTime / tickTime) > tickCount {
            tickCount += 1
            tickDamage.inflict(using: .none, on: entity, from: source)
        }
    }
}
