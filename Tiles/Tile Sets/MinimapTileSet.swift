//
//  MinimapTileSet.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The `TileSet` used by the UI Minimap.
///
class MinimapTileSet: TileSet, TextureUser {
    
    static var textureNames: Set<String> {
        let floor = "Minimap_Floor"
        let wall = "Minimap_Wall"
        let innerCorner = "Minimap_Inner_Corner"
        let outerCorner = "Minimap_Outer_Corner"
        return [floor, wall, innerCorner, outerCorner]
    }
    
    /// The instance of the class.
    ///
    static let instance = MinimapTileSet()
    
    let cellSize: CGSize
    let cellOffset: CGFloat
    let floorSize: CGSize
    let wallSize: CGSize
    let innerCornerSize: CGSize
    let outerCornerSize: CGSize
    
    private init() {
        cellSize = CGSize(width: 2.0, height: 2.0)
        cellOffset = 4.0
        floorSize = CGSize(width: 2.0, height: 2.0)
        wallSize = CGSize(width: 2.0, height: 8.0)
        innerCornerSize = CGSize(width: 8.0, height: 8.0)
        outerCornerSize = CGSize(width: 8.0, height: 8.0)
    }
    
    func makeFloor(zRotation: CGFloat) -> Tile {
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: "Minimap_Floor"), size: floorSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
    
    func makeWall(zRotation: CGFloat) -> Tile {
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: "Minimap_Wall"), size: wallSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
    
    func makeInnerCorner(zRotation: CGFloat) -> Tile {
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: "Minimap_Inner_Corner"),
                        size: innerCornerSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
    
    func makeOuterCorner(zRotation: CGFloat) -> Tile {
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: "Minimap_Outer_Corner"),
                        size: outerCornerSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
}
