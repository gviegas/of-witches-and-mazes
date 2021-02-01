//
//  CursorResponder.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/19/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol to be implemented by objects that wish to respond to cursor interactions.
///
protocol CursorResponder {
    
    /// Responds to cursor over interactions.
    ///
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    func cursorOver() -> Bool
    
    /// Responds to cursor out interactions.
    ///
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    func cursorOut() -> Bool
    
    /// Responds to cursor selected interactions.
    ///
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    func cursorSelected() -> Bool
    
    /// Responds to cursor unselected interactions.
    ///
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    func cursorUnselected() -> Bool
}
