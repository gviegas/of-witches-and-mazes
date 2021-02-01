//
//  ConcealCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that conceals an entity.
///
class ConcealCondition: Condition {
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation? = nil
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - isResettable: The flag stating whether or not the condition is resettable.
    ///   - duration: An optional duration for the condition. Note that setting the `duration`
    ///     as `nil` causes the affected target to stay concealed indefinitely.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(isResettable: Bool, duration: TimeInterval?, source: Entity?, sfx: SoundFX?) {
        isExclusive = true
        self.isResettable = isResettable
        self.duration = duration
        self.source = source
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1,
            let concealmentComponent = entity.component(ofType: ConcealmentComponent.self),
            let spriteComponent = entity.component(ofType: SpriteComponent.self)
            else { return false }
        
        concealmentComponent.increaseConcealment()
        spriteComponent.colorize(colorAnimation: .concealed)
        
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let concealmentComponent = entity.component(ofType: ConcealmentComponent.self),
            let spriteComponent = entity.component(ofType: SpriteComponent.self)
            else { return false }
        
        concealmentComponent.decreaseConcealment()
        spriteComponent.colorize(colorAnimation: .revealed)
        
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
