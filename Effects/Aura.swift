//
//  Aura.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the aura, used by the `AuraComponent`.
///
class Aura: Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The flag indicating whether the instance represents a hostile or friendly aura.
    ///
    let isHostile: Bool
    
    /// The radius of the aura.
    ///
    let radius: CGFloat
    
    /// The time it takes for the aura to refresh.
    ///
    let refreshTime: TimeInterval
    
    /// The flag stating whether or not the aura should appear in front of other contents.
    ///
    let alwaysInFront: Bool
    
    /// The flag stating whether dispelling effects can affect the aura.
    ///
    let affectedByDispel: Bool
    
    /// The optional duration for the aura.
    ///
    let duration: TimeInterval?
    
    /// The damage of the aura, which may be reapplied after a refresh.
    ///
    let damage: Damage?
    
    /// The healing of the aura, which may be reapplied after a refresh.
    ///
    let healing: Healing?
    
    /// The conditions that the aura applies.
    ///
    /// - Note: This conditions must have duration equal or higher than `refreshTime`, since the
    ///   `AuraComponent` will reset the conditions after every `refreshTime` interval.
    ///   Also, since the conditions are not removed by the `AuraComponent`, duration must not be `nil`.
    ///
    let conditions: [Condition]?
    
    /// The optional `Animation` for the aura.
    ///
    let animation: Animation?
    
    /// The optional `SoundFX` to play when the aura becomes active.
    ///
    let sfx: SoundFX?
    
    /// Creates a new instance representing a hostile aura.
    ///
    /// - Parameters:
    ///   - radius: The radius of the aura.
    ///   - refreshTime: The time it should take for the aura to refresh.
    ///   - alwaysInFront: A flag stating whether or not the aura should appear in front of other contents.
    ///   - affectedByDispel: A flag stating whether dispelling effects can affect the aura.
    ///   - duration: An optional duration for the aura.
    ///   - damage: An optional damage to apply on affected targets.
    ///   - conditions: An optional list of conditions to apply on affected targets.
    ///   - animation: An optional animation for the aura.
    ///   - sfx: An optional sound effect for the aura.
    ///
    init(radius: CGFloat, refreshTime: TimeInterval, alwaysInFront: Bool, affectedByDispel: Bool,
         duration: TimeInterval?, damage: Damage?, conditions: [Condition]?, animation: Animation?, sfx: SoundFX?) {
        
        isHostile = true
        healing = nil
        self.radius = radius
        self.refreshTime = refreshTime
        self.alwaysInFront = alwaysInFront
        self.affectedByDispel = affectedByDispel
        self.duration = duration
        self.damage = damage
        self.conditions = conditions
        self.animation = animation
        self.sfx = sfx
    }
    
    /// Creates a new instance representing a friendly aura.
    ///
    /// - Parameters:
    ///   - radius: The radius of the aura.
    ///   - refreshTime: The time it should take for the aura to refresh.
    ///   - alwaysInFront: A flag stating whether or not the aura should appear in front of other contents.
    ///   - affectedByDispel: A flag stating whether dispelling effects can affect the aura.
    ///   - duration: An optional duration for the aura.
    ///   - healing: An optional healing to apply on affected targets.
    ///   - conditions: An optional list of conditions to apply on affected targets.
    ///   - animation: An optional animation for the aura.
    ///   - sfx: An optional sound effect for the aura.
    ///
    init(radius: CGFloat, refreshTime: TimeInterval, alwaysInFront: Bool, affectedByDispel: Bool,
         duration: TimeInterval?, healing: Healing?, conditions: [Condition]?, animation: Animation?, sfx: SoundFX?) {
        
        isHostile = false
        damage = nil
        self.radius = radius
        self.refreshTime = refreshTime
        self.alwaysInFront = alwaysInFront
        self.affectedByDispel = affectedByDispel
        self.duration = duration
        self.healing = healing
        self.conditions = conditions
        self.animation = animation
        self.sfx = sfx
    }
}
