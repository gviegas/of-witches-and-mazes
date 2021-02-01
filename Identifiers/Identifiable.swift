//
//  Identifiable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/9/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that represents an instance's unique identifier.
///
protocol Identifiable {
    
    /// The unique identifier of the instance.
    ///
    var identifier: String { get }
}
