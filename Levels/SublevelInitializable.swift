//
//  SublevelInitializable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that enables `Level` types to initialize from a given sublevel number.
///
protocol SublevelInitializable: Level {
    
    /// Creates a new instance starting from the given sublevel.
    ///
    /// The main purpose of this initializer is to allow the reinitialization of a `Level` that
    /// was only partially completed (i.e., one that has not run through all its sublevels).
    ///
    /// - Parameter currentSublevel: The sublevel to start at.
    ///
    init?(currentSublevel: Int)
}
