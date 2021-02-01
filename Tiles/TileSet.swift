//
//  TileSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/31/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines a tile set.
///
protocol TileSet {
    
    /// The base size of a tile cell in this set.
    ///
    /// Notice that a Tile do not need to be exactly this size, but must be a multiple.
    /// For example, a wall could have four times this size as height and one time as width.
    ///
    var cellSize: CGSize { get }
    
    /// The offset, in cells (i.e., tiles), that walls and corners created by this set will use.
    ///
    /// This value is meant to indicate exactly how many cells that the walls and corners will 'invade'
    /// in a given room area. For example, a wall with height equal (cellSize * 4) will occupy four tiles
    /// inside a room.
    ///
    /// - Note: This value is used extensively by many `Maze` operations, so care must be taken for it to
    ///   always be correctly set. Also note that it is expected that the corners height and width match
    ///   the wall height.
    ///
    var cellOffset: CGFloat { get }
    
    /// The size of a floor tile created by this set.
    ///
    /// For most cases, this value should be the same as cellSize, i.e., a floor should be of
    /// a single cell (tile) in size.
    ///
    var floorSize: CGSize { get }
    
    /// The size of a wall tile created by this set.
    ///
    /// For most cases, this value should be equal one cellSize in width, and its height must
    /// match the corners dimensions.
    ///
    var wallSize: CGSize { get }
    
    /// The size of an inner-corner tile created by this set.
    ///
    /// For most cases, this value should have the same height and width, and they must be equal
    /// the wallSize height.
    ///
    var innerCornerSize: CGSize { get }
    
    /// The size of an outer-corner tile created by this set.
    ///
    /// For most cases, this value should have the same height and width, and they must be equal
    /// the wallSize height.
    ///
    var outerCornerSize: CGSize { get }
    
    /// Creates a `Tile` to be used as a floor.
    ///
    /// The tile returned by this function is expected to be of `floorSize` in size.
    ///
    /// - Parameter zRotation: The rotation of the tile around the z axis.
    /// - Returns: A `Tile` instance representing a floor.
    ///
    func makeFloor(zRotation: CGFloat) -> Tile
    
    /// Creates a `Tile` to be used as a wall.
    ///
    /// The tile returned by this function is expected to be of `wallSize` in size.
    ///
    /// - Parameter zRotation: The rotation of the tile around the z axis.
    /// - Returns: A `Tile` instance representing a wall.
    ///
    func makeWall(zRotation: CGFloat) -> Tile
    
    /// Creates a `Tile` to be used as an inner-corner wall.
    ///
    /// The tile returned by this function is expected to be of `innerCornerSize` in size.
    ///
    /// - Parameter zRotation: The rotation of the tile around the z axis.
    /// - Returns: A `Tile` instance representing a inner-corner.
    ///
    func makeInnerCorner(zRotation: CGFloat) -> Tile
    
    /// Creates a `Tile` to be used as an outer-corner wall.
    ///
    /// The tile returned by this function is expected to be of `outerCornerSize` in size.
    ///
    /// - Parameter zRotation: The rotation of the tile around the z axis.
    /// - Returns: A `Tile` instance representing an outer-corner.
    ///
    func makeOuterCorner(zRotation: CGFloat) -> Tile
}
