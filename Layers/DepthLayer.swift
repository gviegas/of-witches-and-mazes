//
//  DepthLayer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/21/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that defines ranges of depth values to use on different kinds of layers.
///
struct DepthLayer {
    
    /// The depth values for tiles.
    ///
    static let tiles: Range<CGFloat> = 0..<32.0
    
    /// The depth values for shadows.
    ///
    static let shadows: Range<CGFloat> = tiles.upperBound..<tiles.upperBound + 32.0
    
    /// The depth values for contents.
    ///
    /// Although the upper bound of this range could have been taken from the current
    /// level boundaries, a constant value was set here to avoid computing this property
    /// multiple times.
    ///
    /// This range should be large enough to use for the contents' depth. For example,
    /// a `Maze` with cell size of 256 points and room size of 30 cells could have up to
    /// 12 rows of rooms, which should be more than enough for a single sublevel of a
    /// `Level` instance. In any case, it is safer to stay within this range, otherwise
    /// the computations may become unstable.
    ///
    static let contents: Range<CGFloat> = shadows.upperBound..<96_000.0
    
    /// The depth values for decorators.
    ///
    /// This range is meant for UI-like things associated with an entity, like floating
    /// bars and labels.
    ///
    static let decorators: Range<CGFloat> = contents.upperBound..<contents.upperBound + 32.0
    
    /// The depth value for overlays.
    ///
    static let overlays: Range<CGFloat> = decorators.upperBound..<decorators.upperBound + 32.0
    
    /// The depth value for the cursor.
    ///
    static let cursor: Range<CGFloat> = overlays.upperBound..<overlays.upperBound + 16.0
}
