//
//  Missile.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/19/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the missile, used by the `MissileComponent`.
///
class Missile: Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The medium used to deliver the missile.
    ///
    let medium: Medium
    
    /// The range of the missile.
    ///
    let range: CGFloat
    
    /// The speed of the missile.
    ///
    let speed: CGFloat
    
    /// The size of the missile.
    ///
    let size: CGSize
    
    /// The time it takes for the missile to be fired.
    ///
    let delay: TimeInterval
    
    /// The time it takes to finish the missile's fire event.
    ///
    let conclusion: TimeInterval
    
    /// A flag stating whether or not the missile must dissipate when hitting a target.
    ///
    let dissipateOnHit: Bool
    
    /// The `Damage` instance representing the damage of the missile.
    ///
    let damage: Damage?
    
    /// The `Condition`s that the missile applies on targets.
    ///
    let conditions: [Condition]?
    
    /// The optional `Animation` instances for the missile.
    ///
    let animation: (initial: Animation?, main: Animation?, final: Animation?)?
    
    /// The optional `SoundFX` to play when executing the missile.
    ///
    let sfx: SoundFX?
    
    /// Creates a nw instance from the given values.
    ///
    /// - Parameters:
    ///   - medium: The missile's medium.
    ///   - range: The missile's range.
    ///   - speed: The missile's speed.
    ///   - size: The missile's size.
    ///   - delay: The time to wait before firing the missile.
    ///   - conclusion: The time to wait before concluding the missile's firing.
    ///   - dissipateOnHit: A flag stating if the missile must dissipate on hit.
    ///   - damage: An optional `Damage` instance for the missile.
    ///   - conditions: An optional list of `Condition`s for the missile.
    ///   - animation: An optional tuple containing the animations for the missile.
    ///   - sfx: An optional sound effect for the missile.
    ///
    init(medium: Medium, range: CGFloat, speed: CGFloat, size: CGSize, delay: TimeInterval,
         conclusion: TimeInterval, dissipateOnHit: Bool, damage: Damage?, conditions: [Condition]?,
         animation: (initial: Animation?, main: Animation?, final: Animation?)?, sfx: SoundFX?) {
        
        self.medium = medium
        self.range = range
        self.speed = speed
        self.size = size
        self.delay = delay
        self.conclusion = conclusion
        self.dissipateOnHit = dissipateOnHit
        self.damage = damage
        self.conditions = conditions
        self.animation = animation
        self.sfx = sfx
    }
}
