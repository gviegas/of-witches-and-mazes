//
//  ActionComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the action delegate, used by the `ActionComponent` when it
/// performs an action.
///
protocol ActionDelegate: AnyObject {
    
    /// Informs the delegate that an action was performed.
    ///
    /// - Parameters:
    ///   - action: The `Action` performed.
    ///   - entity: The `Entity` instance that performed the action.
    ///
    func didAct(_ action: Action, entity: Entity)
}

/// A component that allows an entity to perform general actions.
///
class ActionComponent: Component {
    
    /// The current action.
    ///
    var action: Action?
    
    /// The subject of the action.
    ///
    weak var subject: Entity?
    
    /// The action delegate.
    ///
    weak var delegate: ActionDelegate?
}
