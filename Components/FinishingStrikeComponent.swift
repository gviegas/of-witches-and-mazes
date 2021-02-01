//
//  FinishingStrikeComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to cause additional damage to wounded targets.
///
class FinishingStrikeComponent: Component {
    
    /// The bonus applied to damage.
    ///
    let damageBonus: Double
    
    /// The flag stating whether the component will remove itself from its entity
    /// after `applyFinishingStrikeTo(damage:against:)` is called.
    ///
    let isSelfRemovable: Bool
    
    /// Creates a new instance from the given damage bonus and self-removable flag.
    ///
    /// - Parameters:
    ///   - damageBonus: The bonus multiplier to apply to damage on the finishing strike.
    ///   - isSelfRemovable: The flag stating whether the component must remove itself from its entity
    ///     after `applyFinishingStrikeTo(damage:against:)` is called.
    ///
    init(damageBonus: Double, isSelfRemovable: Bool) {
        self.damageBonus = damageBonus
        self.isSelfRemovable = isSelfRemovable
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Applies the finishing strike modifier to the given damage, as if it was caused against
    /// the given target entity.
    ///
    /// - Parameters:
    ///   - damage: The damage to modify.
    ///   - target: The entity hit by the strike.
    /// - Returns: The new amount of damage.
    ///
    func applyFinishingStrikeTo(damage: Int, against target: Entity) -> Int {
        defer {
            if isSelfRemovable { entity?.removeComponent(ofType: FinishingStrikeComponent.self) }
        }
        
        guard let healthComponent = target.component(ofType: HealthComponent.self) else { return damage }
        
        let isWounded = healthComponent.currentHP != healthComponent.totalHp
        return isWounded ? damage + Int((Double(damage) * damageBonus).rounded()) : damage
    }
}
