//
//  ImmunityCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that makes an entity immune to a type of damage.
///
class ImmunityCondition: Condition {
    
    /// The `DamageType` to be affected.
    ///
    let damageType: DamageType
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - damageType: The `DamageType` to be affected.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(damageType: DamageType, isExclusive: Bool, isResettable: Bool, duration: TimeInterval?,
         source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        
        self.damageType = damageType
        self.isExclusive = isExclusive
        self.isResettable = isResettable
        self.duration = duration
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1,
            let immunityComponent = entity.component(ofType: ImmunityComponent.self)
            else { return false }
        
        return immunityComponent.immunities.insert(.damage(damageType)).inserted
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let immunityComponent = entity.component(ofType: ImmunityComponent.self) else { return false }
        
        immunityComponent.immunities.remove(.damage(damageType))
        if color != nil { entity.component(ofType: SpriteComponent.self)?.colorize(colorAnimation: .cleared) }
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
