//
//  AnimationUser.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/10/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that enables a type to state its intention to use a set of animations.
///
protocol AnimationUser {
    
    /// The set containing the `AnimationSource` keys of all animations that the type intends to use.
    ///
    static var animationKeys: Set<String> { get }
}
