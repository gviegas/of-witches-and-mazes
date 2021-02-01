//
//  HamperCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that hampers the movement of an entity.
///
class HamperCondition: Condition {
    
    /// The slow factor that the condition provides, between `0` and `1.0`.
    ///
    /// Values close to `1.0` will greatly reduce the entity's speed, while values close to `0` will
    /// slow down its movement just slightly.
    ///
    let slowFactor: CGFloat
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - slowFactor: A value between `0` and `1.0` representing the percentage to reduce from speed.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(slowFactor: CGFloat, isExclusive: Bool, isResettable: Bool, duration: TimeInterval?,
         source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        
        self.slowFactor = slowFactor
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
            !movementComponent.isMultiplierLowerCapped()
            else { return false }
        
        movementComponent.modifyMultiplier(by: -slowFactor)
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { return false }
        
        movementComponent.modifyMultiplier(by: slowFactor)
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
