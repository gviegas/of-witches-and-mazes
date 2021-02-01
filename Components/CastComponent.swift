//
//  CastComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that represents the kinds of spells.
///
enum SpellKind {
    case throwing
    case ray
    case missile
    case barrier
    case targetBlast, localBlast
    case targetInfluence, localInfluence
    case targetTouch, localTouch
}

/// A struct that represents the `Spell`, used by the `CastComponent`.
///
struct Spell {
    
    /// The spell kind.
    ///
    let kind: SpellKind
    
    /// The spell effect.
    ///
    /// This property must hold a `Throwing`, `Missile`, `Ray`, `Barrier`, `Blast`,
    /// `Influence` or `Touch` instance.
    ///
    let effect: Any
    
    /// The cast time.
    ///
    let castTime: (delay: TimeInterval, duration: TimeInterval, conclusion: TimeInterval)
}

/// A component that enables an entity to cause different types of effects as spell casts.
///
class CastComponent: Component {
    
    /// The next spell to cast.
    ///
    var spell: Spell?
    
    /// The spell book to use when casting the next spell, defining its resource cost.
    ///
    weak var spellBook: ResourceItem?
}
