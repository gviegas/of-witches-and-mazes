//
//  GridGraph.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/3/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A structure that represents a single vertex in a `GridGraph`.
///
/// This type of vertex is defined by a two-dimensional point, with the x and y coordinates
/// rounded to the nearest integral values.
///
struct GridVertex: Hashable {
    
    /// The point that represents this vertex.
    ///
    let point: CGPoint
    
    /// Creates a new instance from the given point.
    ///
    /// - Parameter point: The point value.
    ///
    init(point: CGPoint) {
        self.point = CGPoint(x: point.x.rounded(), y: point.y.rounded())
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
    
    static func ==(lhs: GridVertex, rhs: GridVertex) -> Bool {
        return lhs.point == rhs.point
    }
}

/// A graph subclass whose vertices are rounded two-dimensional points.
///
class GridGraph: Graph<GridVertex, UInt> {}
