//
//  PortraitComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/16/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with a `Portrait`.
///
class PortraitComponent: Component {
    
    /// The `Portrait` type of the entity.
    ///
    var portrait: Portrait {
        didSet { broadcast() }
    }
    
    /// Creates a new instance from the given portrait and size values.
    ///
    /// - Parameter portrait: The `Portrait` to use.
    ///
    init(portrait: Portrait) {
        self.portrait = portrait
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
