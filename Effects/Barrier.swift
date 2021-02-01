//
//  Barrier.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines the barrier, used by the `BarrierComponent`.
///
class Barrier: Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The amount of damage that the barrier mitigates.
    ///
    let mitigation: Int
    
    /// The flag stating whether or not the mitigation value is to be interpreted as depletable.
    ///
    let isDepletable: Bool
    
    /// The flag stating whether dispelling effects can affect the barrier.
    ///
    let affectedByDispel: Bool
    
    /// The size of the barrier.
    ///
    let size: CGSize
    
    /// The optional duration for the barrier.
    ///
    let duration: TimeInterval?
    
    /// The optional `Animation` instances for the barrier.
    ///
    let animation: (initial: Animation?, main: Animation?, final: Animation?)?
    
    /// The optional `SoundFX` to play when the barrier becomes active.
    ///
    let sfx: SoundFX?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - mitigation: The amount of mitigation that the barrier provides.
    ///   - isDepletable: A flag stating whether or not the mitigation depletes when absorbing damage.
    ///   - affectedByDispel: A flag stating whether dispelling effects can affect the aura.
    ///   - size: The size of the barrier, for animation purposes.
    ///   - duration: An optional duration for the barrier.
    ///   - animation: An optional tuple containing the animations for the barrier.
    ///   - sfx: An optional sound effect for the barrier.
    ///
    init(mitigation: Int, isDepletable: Bool, affectedByDispel: Bool, size: CGSize, duration: TimeInterval?,
         animation: (initial: Animation?, main: Animation?, final: Animation?)?, sfx: SoundFX?) {
        
        self.mitigation = mitigation
        self.isDepletable = isDepletable
        self.affectedByDispel = affectedByDispel
        self.size = size
        self.duration = duration
        self.animation = animation
        self.sfx = sfx
    }
}
