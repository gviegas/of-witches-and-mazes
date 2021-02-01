//
//  Action.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that defines a general action, used by the `ActionComponent`.
///
class Action {
    
    /// The time it takes to start the action.
    ///
    let delay: TimeInterval
    
    /// The duration of the action.
    ///
    let duration: TimeInterval
    
    /// The time it takes to end the action.
    ///
    let conclusion: TimeInterval
    
    /// The optional `SoundFX` instances to play when executing the action.
    ///
    let sfx: (before: SoundFX?, during: SoundFX?, after: SoundFX?)?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - delay: The time it takes to start the action.
    ///   - duration: The duration of the action.
    ///   - conclusion: The time it takes to end the action.
    ///   - sfx: An optional tuple containing the sound effects for the action.
    ///
    init(delay: TimeInterval, duration: TimeInterval, conclusion: TimeInterval,
         sfx: (before: SoundFX?, during: SoundFX?, after: SoundFX?)?) {
        self.delay = delay
        self.duration = duration
        self.conclusion = conclusion
        self.sfx = sfx
    }
}
