//
//  CondemnCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type defining the Condemn condition, a delayed damage that is applied on removal.
///
class CondemnCondition: Condition {
    
    /// The damage instance.
    ///
    let damage: Damage
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - delay: The time to wait before applying damage and finishing the condition.
    ///   - damage: The damage to inflict after the delay interval has elapsed.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(delay: TimeInterval, damage: Damage, isExclusive: Bool, source: Entity?, color: ColorAnimation?,
        sfx: SoundFX?) {
        
        isResettable = false
        self.duration = delay
        self.damage = damage
        self.isExclusive = isExclusive
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        return applicationNumber == 1
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        if entity.component(ofType: HealthComponent.self)?.isDead != true {
            damage.inflict(using: .none, on: entity, from: source)
        }
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
