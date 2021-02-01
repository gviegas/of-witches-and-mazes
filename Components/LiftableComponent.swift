//
//  LiftableComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/20/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to be lifted by another.
///
class LiftableComponent: Component {
    
    /// The flag stating whether or not the entity can be lifted by another.
    ///
    var canBeLifted: Bool {
        return liftSubject == nil
    }
    
    /// The hurl interaction.
    ///
    var hurlInteraction: Interaction? {
        return liftSubject?.component(ofType: LiftComponent.self)?.hurlInteraction
    }
    
    /// The hurl damage.
    ///
    var hurlDamage: Damage?
    
    /// The target point for the next hurling.
    ///
    var hurlTarget: CGPoint?
    
    /// The entity currently lifting this one.
    ///
    weak var liftSubject: Entity?
    
    /// Creates a new instance from the given damage.
    ///
    /// - Parameter hurlDamage: The optional `Damage` to be applied when hurled against.
    ///
    init(hurlDamage: Damage?) {
        self.hurlDamage = hurlDamage
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
