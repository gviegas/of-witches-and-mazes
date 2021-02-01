//
//  Blast.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the blast effect, used by the `BlastComponent.`.
///
class Blast: Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The medium used to deliver the blast.
    ///
    let medium: Medium
    
    /// The initial size of the blast.
    ///
    let initialSize: CGSize
    
    /// The final size of the blast.
    ///
    let finalSize: CGSize
    
    /// The maximum range limiting where the blast originates.
    ///
    let range: CGFloat
    
    /// The time it takes for the blast to start.
    ///
    let delay: TimeInterval
    
    /// The duration of the blast, not considering the delay nor the conclusion.
    ///
    /// This property dictates how fast (or slow) the blast spreads - i.e., change from `initialSize`
    /// to `finalSize`.
    ///
    let duration: TimeInterval
    
    /// The time it takes for the blast to end.
    ///
    let conclusion: TimeInterval
    
    /// The `Damage` instance representing the damage of the blast.
    ///
    let damage: Damage?
    
    /// The `Condition`s that the blast applies on targets.
    ///
    let conditions: [Condition]?
    
    /// The optional `Animation` instances for the blast.
    ///
    let animation: (initial: Animation?, main: Animation?, final: Animation?)?
    
    /// The optional `SoundFX` to play when executing the blast.
    ///
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - medium: The blast's medium.
    ///   - initialSize: The initial size of the blast.
    ///   - finalSize: The final size of the blast.
    ///   - range: The blast's range.
    ///   - delay: The delay until the blasts starts spreading.
    ///   - duration: The duration of the blast, not considering the initial delay.
    ///   - conclusion: The time to wait after `duration`.
    ///   - damage: An optional `Damage` instance for the blast.
    ///   - conditions: An optional list of `Condition`s for the blast.
    ///   - animation: An optional tuple containing the animations for the blast.
    ///   - sfx: An optional sound effect for the blast.
    ///
    init(medium: Medium, initialSize: CGSize, finalSize: CGSize, range: CGFloat,
         delay: TimeInterval, duration: TimeInterval, conclusion: TimeInterval,
         damage: Damage?, conditions: [Condition]?,
         animation: (initial: Animation?, main: Animation?, final: Animation?)?, sfx: SoundFX?) {
        
        self.medium = medium
        self.initialSize = initialSize
        self.finalSize = finalSize
        self.range = range
        self.delay = delay
        self.duration = duration
        self.conclusion = conclusion
        self.damage = damage
        self.conditions = conditions
        self.animation = animation
        self.sfx = sfx
    }
}
