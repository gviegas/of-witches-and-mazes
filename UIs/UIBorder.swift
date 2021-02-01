//
//  UIBorder.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that represents a rect's border.
///
struct UIBorder {
    
    /// The width of the top edge of the border.
    ///
    let top: CGFloat
    
    /// The width of the bottom edge of the border.
    ///
    let bottom: CGFloat
    
    /// The width of the left edge of the border.
    ///
    let left: CGFloat
    
    /// The width of the right edge of the border.
    ///
    let right: CGFloat
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - top: The width for the top edge.
    ///   - bottom: The width for the bottom edge.
    ///   - left: The width for the left edge.
    ///   - right: The width for the right edge.
    ///
    init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
    
    /// Creates a new instance with the same width on all sides of the border.
    ///
    /// - Parameter width: The length to set for all sides.
    ///
    init(width: CGFloat) {
        self.init(top: width, bottom: width, left: width, right: width)
    }
}
