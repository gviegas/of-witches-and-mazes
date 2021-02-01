//
//  QuellCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that makes an entity unable to act.
///
class QuellCondition: Condition {
    
    let isExclusive: Bool
    let isResettable: Bool
    let duration: TimeInterval?
    weak var source: Entity?
    let color: ColorAnimation?
    let sfx: SoundFX?
    
    /// The `Quelling` instance that the condition uses.
    ///
    private let quelling: Quelling
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - quelling: A `Quelling` instance defining the quell parameters.
    ///   - source: An optional entity to be identified as the source of the condition.
    ///   - color: An optional color animation to use when applying the condition.
    ///   - sfx: An optional sound effect to play when applying the condition.
    ///
    init(quelling: Quelling, source: Entity?, color: ColorAnimation?, sfx: SoundFX?) {
        isExclusive = true
        isResettable = false
        duration = quelling.duration
        self.quelling = quelling
        self.source = source
        self.color = color
        self.sfx = sfx
    }
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard let quellComponent = entity.component(ofType: QuellComponent.self),
            let stateComponent = entity.component(ofType: StateComponent.self),
            stateComponent.canEnter(namedState: .quelled)
            else { return false }
        
        quellComponent.quelling = quelling
        return stateComponent.enter(namedState: .quelled)
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else { return false }
        return stateComponent.enter(namedState: .standard)
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
