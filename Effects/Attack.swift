//
//  Attack.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/27/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the attack, used by the `AttackComponent`.
///
class Attack: Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The medium used to deliver the attack.
    ///
    let medium: Medium
    
    /// The `Damage` instance representing the damage of the attack.
    ///
    let damage: Damage
    
    /// The reach of the attack.
    ///
    let reach: CGFloat
    
    /// The broadness of the attack.
    ///
    let broadness: CGFloat
    
    /// The time it takes for the attack to start.
    ///
    let delay: TimeInterval
    
    /// The total duration of the attack, not considering the initial delay nor the conclusion.
    ///
    let duration: TimeInterval
    
    /// The time it takes for the attack to end.
    ///
    let conclusion: TimeInterval
    
    /// The conditions applied by the attack when hitting a target.
    ///
    let conditions: [Condition]?
    
    /// The optional `SoundFX` to play when executing the attack.
    ///
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - medium: The attack's medium.
    ///   - damage: The `Damage` instance for the attack.
    ///   - reach: The reach of the attack.
    ///   - broadness: The broadness of the attack.
    ///   - delay: The delay until the attack starts its execution.
    ///   - duration: The total time for the attack to complete its execution.
    ///   - conclusion: The time to wait for attack conclusion, after `duration` has elapsed.
    ///   - conditions: An optional list of `Conditions` to apply on targets.
    ///   - sfx: An optional sound effect for the attack.
    ///
    init(medium: Medium, damage: Damage, reach: CGFloat, broadness: CGFloat,
         delay: TimeInterval, duration: TimeInterval, conclusion: TimeInterval,
         conditions: [Condition]?, sfx: SoundFX?) {
        
        self.medium = medium
        self.damage = damage
        self.reach = abs(reach)
        self.broadness = abs(broadness)
        self.delay = delay
        self.duration = duration
        self.conclusion = conclusion
        self.conditions = conditions
        self.sfx = sfx
    }
}
