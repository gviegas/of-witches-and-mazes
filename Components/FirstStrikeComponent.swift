//
//  FirstStrikeComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to cause additional damage on the first strike.
///
class FirstStrikeComponent: Component {
    
    /// The bonus applied to damage.
    ///
    let damageBonus: Double
    
    /// Creates a new instance from the given damage bonus.
    ///
    /// - Parameter damageBonus: The bonus multiplier to apply to damage on the first strike.
    ///
    init(damageBonus: Double) {
        self.damageBonus = damageBonus
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Applies the first strike modifier to the given damage, as if it was caused against the
    /// given target entity.
    ///
    /// - Parameters:
    ///   - damage: The damage to modify.
    ///   - target: The entity hit by the strike.
    /// - Returns: The new amount of damage.
    ///
    func applyFirstStrikeTo(damage: Int, against target: Entity) -> Int {
        guard let healthComponent = target.component(ofType: HealthComponent.self) else { return damage }
        
        let isWounded = healthComponent.currentHP != healthComponent.totalHp
        return !isWounded ? damage + Int((Double(damage) * damageBonus).rounded()) : damage
    }
}
