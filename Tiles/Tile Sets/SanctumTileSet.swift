//
//  Sanctum.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The `TileSet` representing the Sanctum.
///
class SanctumTileSet: TileSet, TextureUser {
    
    static var textureNames: Set<String> {
        let floor = ImageArray.createFrom(baseName: "Sanctum_Floor_", first: 1, last: 10)
        let wall = ImageArray.createFrom(baseName: "Sanctum_Wall_", first: 1, last: 4)
        let innerCorner = ImageArray.createFrom(baseName: "Sanctum_Inner_Corner_", first: 1, last: 2)
        let outerCorner = ImageArray.createFrom(baseName: "Sanctum_Outer_Corner_", first: 1, last: 2)
        return Set<String>(floor + wall + innerCorner + outerCorner)
    }
    
    /// The instance of the class.
    ///
    static let instance = SanctumTileSet()
    
    let cellSize: CGSize
    let cellOffset: CGFloat
    let floorSize: CGSize
    let wallSize: CGSize
    let innerCornerSize: CGSize
    let outerCornerSize: CGSize
    
    private init() {
        cellSize = CGSize(width: 64.0, height: 64.0)
        cellOffset = 4.0
        floorSize = CGSize(width: 64.0, height: 64.0)
        wallSize = CGSize(width: 64.0, height: 256.0)
        innerCornerSize = CGSize(width: 256.0, height: 256.0)
        outerCornerSize = CGSize(width: 256.0, height: 256.0)
    }
    
    func makeFloor(zRotation: CGFloat) -> Tile {
        let image = "Sanctum_Floor_\(Int.random(in: 1...10))"
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: image), size: floorSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
    
    func makeWall(zRotation: CGFloat) -> Tile {
        let image = "Sanctum_Wall_\(Int.random(in: 1...4))"
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: image), size: wallSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
    
    func makeInnerCorner(zRotation: CGFloat) -> Tile {
        let image = "Sanctum_Inner_Corner_\(Int.random(in: 1...2))"
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: image), size: innerCornerSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
    
    func makeOuterCorner(zRotation: CGFloat) -> Tile {
        let image = "Sanctum_Outer_Corner_\(Int.random(in: 1...2))"
        let tile = Tile(texture: TextureSource.createTexture(imageNamed: image), size: outerCornerSize)
        tile.zRotation = zRotation
        tile.zPosition = DepthLayer.tiles.lowerBound
        return tile
    }
}
