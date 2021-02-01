//
//  HealthReductionCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that reduces the total health points of an entity.
///
class HealthReductionCondition: Condition {
    
    /// The reduction factor that the condition provides, between `0` and `1.0`.
    ///
    /// Values close to `1.0` will greatly reduce the entity's health points, while values close to `0`
    /// will reduce it just slightly. A value of `1.0` means that the entity's health points will be set
    /// to the minimum, unless there is some health points increment currently active.
    ///
    let reductionFactor: Double
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - reductionFactor: A value between `0` and `1.0` representing the percentage to reduce from health.
    ///   - isExclusive: The flag stating whether or not the condition is exclusive.
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(reductionFactor: Double, isExclusive: Bool, isResettable: Bool, duration: TimeInterval?,
         source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        
        self.reductionFactor = reductionFactor
        self.isExclusive = isExclusive
        self.isResettable = isResettable
        self.duration = duration
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard let healthComponent = entity.component(ofType: HealthComponent.self),
            !healthComponent.isMultiplierLowerCapped()
            else { return false }
        
        healthComponent.modifyMultiplier(by: -reductionFactor)
        
        // ConditionComponent colorizes and plays the sound effect only for the first application, thus
        // it must be done here for every subsequent application
        if applicationNumber > 1 {
            if let color = color, let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                spriteComponent.colorize(colorAnimation: color)
            }
            if let sfx = sfx, let nodeComponent = entity.component(ofType: NodeComponent.self) {
                sfx.play(at: nodeComponent.node.position, sceneKind: .level)
            }
        }
        
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let healthComponent = entity.component(ofType: HealthComponent.self),
            !healthComponent.isDead
            else { return false }
        
        healthComponent.modifyMultiplier(by: reductionFactor * Double(applications))
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
