//
//  ConcealmentComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

/// A component that enables an entity to avoid being noticed by enemies.
///
class ConcealmentComponent: Component {
    
    /// The concealment count.
    ///
    private var concealmentCount = 0 {
        didSet {
            concealmentCount = max(0, concealmentCount)
            broadcast()
        }
    }
    
    /// The flag stating whether the entity is concealed.
    ///
    var isConcealed: Bool {
        return concealmentCount > 0
    }
    
    /// Increases the concealment count.
    ///
    /// Concealment is controlled by a count that keeps track of how many concealing effects were applied.
    /// The entity will only be revealed when all concealment applications are removed with a call to
    /// `decreaseConcealment()`. Thus, it is of utmost importance that every call to `increaseConcealment()`
    /// eventually be followed by exactly one call to `decreaseConcealment()`.
    ///
    func increaseConcealment() {
        concealmentCount += 1
    }
    
    /// Decreases the concealment count.
    ///
    /// Concealment is controlled by a count that keeps track of how many concealing effects were applied
    /// using the `increaseConcealment()` method.
    /// The entity will only be revealed when all concealment applications are removed with a call to
    /// `decreaseConcealment()`. Thus, it is of utmost importance that every call to `increaseConcealment()`
    /// eventually be followed by exactly one call to `decreaseConcealment()`.
    ///
    func decreaseConcealment() {
        concealmentCount -= 1
    }
}
