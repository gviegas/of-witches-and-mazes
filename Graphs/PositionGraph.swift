//
//  PositionGraph.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/28/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A structure that represents a vertex in a `PositionGraph`.
///
/// This type of vertex is defined by a two-dimensional point.
///
struct PositionVertex: Hashable {
    
    /// The point that represents this vertex.
    ///
    let point: CGPoint
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
    
    static func ==(lhs: PositionVertex, rhs: PositionVertex) -> Bool {
        return lhs.point == rhs.point
    }
}

/// A graph subsclass whose vertices are two-dimensional points.
///
class PositionGraph: Graph<PositionVertex, UInt> {}
