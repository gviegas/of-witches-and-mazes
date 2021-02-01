//
//  Controllable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol indicating that a given instance can respond to input.
///
protocol Controllable {
    
    /// Informs the controllable that a new event was received.
    ///
    /// - Parameter event: The new event.
    ///
    func didReceiveEvent(_ event: Event)
}
