//
//  VoiceComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with a voice-like sound effect.
///
class VoiceComponent: Component {
    
    /// An enum that represents a grade of volubleness.
    ///
    enum Volubleness { case low, normal, high }
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a VoiceComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The `SoundFX` instance representing the voice sound effect.
    ///
    let voice: SoundFX
    
    /// The volubleness grade.
    ///
    let volubleness: Volubleness
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - voice: The `SoundFX` instance representing the voice.
    ///   - volubleness: A `VoiceComponent.Volubleness` value representing how voluble the entity is.
    ///     This value controls the likelihood of the voice sound playing when calling `utterByChance()`.
    ///
    init(voice: SoundFX, volubleness: Volubleness) {
        self.voice = voice
        self.volubleness = volubleness
        super.init()
    }
    
    /// Possibly plays the voice sound effect.
    ///
    /// - Note: This method uses the `volubleness` property as the likelihood of the voice playing.
    ///   Even with the `volubleness` set as `high`, there still is a chance that the sound will
    ///   not play. When playback is required, he `voice` property must be used directly.
    ///
    /// - Returns: `true` if the voice sound was set to play, `false` otherwise.
    ///
    @discardableResult
    func utterByChance() -> Bool {
        let flag: Bool
        let rnd = Double.random(in: 0...1.0)
        switch volubleness {
        case .low:
            flag = rnd > 0.9
        case .normal:
            flag = rnd > 0.5
        case .high:
            flag = rnd > 0.1
        }
        if flag { voice.play(at: nodeComponent.node.position, sceneKind: .level) }
        return flag
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
