//
//  CounterComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to counter hostile actions.
///
class CounterComponent: Component {
    
    /// The set defining the types of media that the entity can counter.
    ///
    var counterMedia: Set<Medium>
    
    /// Creates a new instance from the given `Medium` set.
    ///
    /// - Parameter counterMedia: The set defining the types of media that the entity can counter.
    ///
    init(counterMedia: Set<Medium>) {
        self.counterMedia = counterMedia
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Counters a hostile action.
    ///
    /// - Parameters:
    ///   - medium: The `Medium` that carried out the action to counter.
    ///   - target: The `Entity` to be countered.
    ///   - damage: The `Damage` instance to apply.
    ///   - conditions: The `Condition` list holding the conditions to apply.
    /// - Returns: `true` if the entity could counter the action, `false` otherwise.
    ///
    @discardableResult
    func counter(medium: Medium, target: Entity, damage: Damage?, conditions: [Condition]?) -> Bool {
        guard counterMedia.contains(medium) else { return false }
        Combat.carryOutHostileAction(using: medium, on: target, as: nil, damage: damage,
                                     conditions: conditions, unavoidable: true)
        return true
    }
}
