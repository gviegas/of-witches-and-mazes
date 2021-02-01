//
//  TextureUser.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that enables a type to state its intention to use a set of textures.
///
protocol TextureUser {
    
    /// The set containing the names of all textures that the type intends to use.
    ///
    static var textureNames: Set<String> { get }
}
