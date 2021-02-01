//
//  ExtentGraph.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/28/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A structure that represents a single vertex in an `ExtentGraph`.
///
/// This type of vertex is defined by a two-dimensional rectangle.
///
struct ExtentVertex: Hashable {
    
    /// The rect that represents this vertex.
    ///
    let rect: CGRect
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rect.origin.x)
        hasher.combine(rect.origin.y)
        hasher.combine(rect.size.width)
        hasher.combine(rect.size.height)
    }
    
    static func ==(lhs: ExtentVertex, rhs: ExtentVertex) -> Bool {
        return lhs.rect == rhs.rect
    }
}

/// A graph subclass whose vertices are two-dimensional rectangles.
///
class ExtentGraph: Graph<ExtentVertex, UInt> {}
