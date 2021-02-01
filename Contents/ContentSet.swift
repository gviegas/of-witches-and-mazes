//
//  ContentSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines a content set, suitable for content placement.
///
protocol ContentSet {
    
    /// The base size of a content cell in this set.
    ///
    /// This is the minimum space occupied by a single content - any other piece of content is
    /// guaranteed to be positioned at least this value's width or height away.
    ///
    /// - Note: `Maze` classes will not be able to use a `ContentSet` with a `cellSize` that do
    ///   not match their own, and `MazeContentPlacer` classes will use this value to scale positions.
    ///
    var cellSize: CGSize { get }
    
    /// Creates content of the given type.
    ///
    /// - Parameter type: The type of the content to create.
    /// - Returns: The created `Content`, or `nil` if the set is not able to create content of the given type.
    ///
    func makeContent(ofType type: ContentType) -> Content?
}
