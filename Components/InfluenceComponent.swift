//
//  InfluenceComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/15/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to cause `Influence`.
///
class InfluenceComponent: Component {
    
    /// The current influence.
    ///
    var influence: Influence?
    
    /// Causes influence.
    ///
    /// - Parameter origin: The origin of the influence.
    /// - Returns: `true` if the influence could be caused, `false` otherwise.
    ///
    @discardableResult
    func causeInfluence(at origin: CGPoint) -> Bool {
        guard let influence = influence, let level = (entity as? Entity)?.level else { return false }
        
        let influenceNode = InfluenceNode(influence: influence, origin: origin, source: entity as? Entity)
        
        level.addNode(influenceNode)
        
        return true
    }
}
