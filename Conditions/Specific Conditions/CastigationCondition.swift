//
//  CastigationCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `DamageOverTimeCondition` subclass that defines the condition applied by Aura of Castigation.
///
class CastigationCondition: DamageOverTimeCondition {
    
    /// Creates a new instance from the given source entity.
    ///
    /// - Parameter source: The entity that caused the condition.
    ///
    init(source: Entity) {
        guard let progressionComponent = source.component(ofType: ProgressionComponent.self) else {
            fatalError("CastigationCondition requires an entity that has a ProgressionComponent")
        }
        
        let damage = Damage(scale: 1.05, ratio: 0.2, level: progressionComponent.levelOfExperience,
                            modifiers: [.faith: 0.35], type: .spiritual, sfx: nil)
        super.init(tickTime: 3.0, tickDamage: damage, isExclusive: true, isResettable: true, duration: 3.1,
                   source: source, color: nil, sfx: nil)
    }
}
