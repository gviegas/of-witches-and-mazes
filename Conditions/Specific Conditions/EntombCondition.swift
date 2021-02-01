//
//  EntombCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/13/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `QuellCondition` subclass defining the condition applied by the Entomb spell.
///
class EntombCondition: QuellCondition {
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter source: The entity to be identified as the source of the condition.
    ///
    init(source: Entity) {
        super.init(quelling: EntombSkill.quelling, source: source, color: nil, sfx: SoundFXSet.FX.darkHit)
    }
}
