//
//  RetributionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to damage attackers when absorbing their damage.
///
class RetributionComponent: Component {
    
    /// Computes the `Damage` applied by the component.
    ///
    /// - Parameter entity: The entity for which to compute the damage.
    /// - Returns: The component's `Damage`.
    ///
    static func damageFor(entity: Entity) -> Damage {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("`damageFor(entity:)` requires an entity that has a ProgressionComponent")
        }
        
        return Damage(scale: 1.15, ratio: 0.2, level: progressionComponent.levelOfExperience,
                      modifiers: [.faith: 0.5], type: .spiritual, sfx: nil)
    }
    
    /// Punishes a damage attempt.
    ///
    /// - Parameter target: The `Entity` to be punished.
    ///
    func punish(target: Entity) {
        guard target != entity, let entity = entity as? Entity else { return }
        
        let damage = RetributionComponent.damageFor(entity: entity)
        Combat.carryOutHostileAction(using: .spell, on: target, as: entity, damage: damage,
                                     conditions: nil, unavoidable: true)
    }
}
