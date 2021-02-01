//
//  HastenCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

// A `Condition` type that increases the rate of movement of an entity.
///
class HastenCondition: Condition {
    
    /// The haste factor that the condition provides, equal to or higher than `0`.
    ///
    let hasteFactor: CGFloat
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - hasteFactor: A value equal to or higher than `0` representing the percentage to increase.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(hasteFactor: CGFloat, isExclusive: Bool, isResettable: Bool, duration: TimeInterval?,
         source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        
        self.hasteFactor = hasteFactor
        self.isExclusive = isExclusive
        self.isResettable = isResettable
        self.duration = duration
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1,
            let movementComponent = entity.component(ofType: MovementComponent.self),
            !movementComponent.isMultiplierUpperCapped()
            else { return false }
        
        movementComponent.modifyMultiplier(by: hasteFactor)
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else {
            return false
        }
        
        movementComponent.modifyMultiplier(by: -hasteFactor)
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
