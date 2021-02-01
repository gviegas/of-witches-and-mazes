//
//  QuellComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that defines the `Quelling`, used by the `QuellComponent`.
///
struct Quelling {
    
    /// The flag stating whether taking damage will break the quelling effect.
    ///
    let breakOnDamage: Bool
    
    /// The flag stating whether the target will have vulnerability while quelled.
    ///
    let makeVulnerable: Bool
    
    /// The optional duration to remain quelled.
    ///
    let duration: TimeInterval?
}

/// A component that enables an enity to be affected by incapacitating effects.
///
class QuellComponent: Component {
    
    /// The next `Quelling` to use when entering into the entity's quelled state.
    ///
    var quelling: Quelling?
}
