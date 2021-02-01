//
//  Ray.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the ray, used by the `RayComponent`.
///
class Ray: Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The medium used to deliver the ray.
    ///
    let medium: Medium
    
    /// The initial size of the ray.
    ///
    let initialSize: CGSize
    
    /// The final size of the ray.
    ///
    let finalSize: CGSize
    
    /// The time it takes for the ray to start.
    ///
    let delay: TimeInterval
    
    /// The duration of the ray, not considering the delay nor the conclusion.
    ///
    /// This property dictates how fast (or slow) the ray extends - i.e., change from `initialSize`
    /// to `finalSize`.
    ///
    let duration: TimeInterval
    
    /// The time it takes for the ray to end.
    ///
    let conclusion: TimeInterval
    
    /// The `Damage` instance representing the damage of the ray.
    ///
    let damage: Damage?
    
    /// The `Condition`s that the ray applies on targets.
    ///
    let conditions: [Condition]?
    
    /// The optional `Animation` instances for the ray.
    ///
    let animation: (initial: Animation?, main: Animation?, final: Animation?)?
    
    /// The optional `SoundFX` to play when executing the ray.
    ///
    let sfx: SoundFX?
    
    /// The ray's range, equal to `finalSize.width`.
    ///
    var range: CGFloat { return finalSize.width }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - medium: The ray's medium.
    ///   - initialSize: The initial size of the ray.
    ///   - finalalSize: The final size of the ray.
    ///   - delay: The delay until the ray starts.
    ///   - duration: The duration of the ray.
    ///   - conclusion: The time to wait after `duration`.
    ///   - damage: An optional `Damage` instance for the ray.
    ///   - conditions: An optional list of `Condition`s for the ray.
    ///   - animation: An optional tuple containing the animations for the ray.
    ///   - sfx: An optional sound effect for the ray.
    ///
    init(medium: Medium, initialSize: CGSize, finalSize: CGSize,
         delay: TimeInterval, duration: TimeInterval, conclusion: TimeInterval,
         damage: Damage?, conditions: [Condition]?,
         animation: (initial: Animation?, main: Animation?, final: Animation?)?, sfx: SoundFX?) {
        
        self.medium = medium
        self.initialSize = initialSize
        self.finalSize = finalSize
        self.delay = delay
        self.duration = duration
        self.conclusion = conclusion
        self.damage = damage
        self.conditions = conditions
        self.animation = animation
        self.sfx = sfx
    }
}
