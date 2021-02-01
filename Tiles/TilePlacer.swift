//
//  TilePlacer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that places tiles of a `TileSet` as specified by a `Room`.
///
class TilePlacer {
    
    /// The current `TileSet` used to fill a `Room`.
    ///
    var tileSet: TileSet
    
    /// Creates a new instance with the given tile set.
    ///
    /// - Parameter tileSet: The `TileSet` instance to use when creating the tiles.
    ///
    init(tileSet: TileSet) {
        self.tileSet = tileSet
    }
    
    /// Places the tiles from this placer's `TileSet` for the given `Room`, inserting
    /// the tile room sprites as children of the given node.
    ///
    /// - Parameters:
    ///   - room: The `Room` to place the tiles for.
    ///   - node: The node into which append the generated tile sprites.
    ///
    func placeTiles(forRoom room: Room, onNode node: SKNode) {
        
        let size = tileSet.cellSize
        let cellOffset = tileSet.cellOffset
        let floorSize = tileSet.floorSize
        let wallSize = tileSet.wallSize
        let innerCornerSize = tileSet.innerCornerSize
        let outerCornerSize = tileSet.outerCornerSize
        
        ////////////////////////////////////////////////////////////////
        // First, the algorithm will cycle, in a counter-clockwise manner, through each of the four corners
        // of the room rect, checking both adjacent sides of a given corner and adding common walls,
        // inner corners and outer corners as needed
        //
        
        ////////////////////////////////////////////////////////////////
        // From bottom left corner
        //
        if room.westCorridorRect == nil && room.southCorridorRect == nil {
            // Add inner wall to (minX, minY)
            let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi / 2.0)
            innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.width / 2.0,
                                           y: room.roomRect.minY * size.height + innerCornerSize.height / 2.0)
            node.addChild(innerCorner)
            
            // Fill south edge with walls
            for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX - cellOffset) {
                let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                        y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                node.addChild(wall)
            }
        } else if let westCorridor = room.westCorridorRect, let southCorridor = room.southCorridorRect {
            if westCorridor.minY == room.roomRect.minY || southCorridor.minX == room.roomRect.minX {
                // No inner wall
                if westCorridor.minY == room.roomRect.minY && southCorridor.minX == room.roomRect.minX {
                    // Both corridors are on the room boundaries, just add an outer corner
                    let outerCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                    outerCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: room.roomRect.minY * size.height + outerCornerSize.height / 2.0)
                    node.addChild(outerCorner)
                } else if westCorridor.minY == room.roomRect.minY {
                    // Only west corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(room.roomRect.minX)..<Int(southCorridor.minX) {
                        let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                        wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                                y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                    outerCorner.position = CGPoint(x: southCorridor.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: room.roomRect.minY * size.height + outerCornerSize.height / 2.0)
                    node.addChild(outerCorner)
                } else if southCorridor.minX == room.roomRect.minX {
                    // Only south corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(room.roomRect.minY)..<Int(westCorridor.minY) {
                        let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                        wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                                y: CGFloat(i) * size.height + wallSize.width / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                    outerCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.height / 2.0,
                                                   y: westCorridor.minY * size.height + outerCornerSize.width / 2.0)
                    node.addChild(outerCorner)
                }
            } else {
                // None of the corridors are on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi / 2.0)
                innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.width / 2.0,
                                               y: room.roomRect.minY * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and west corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minY + cellOffset)..<Int(westCorridor.minY) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let westOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                westOuterCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.height / 2.0,
                                                   y: westCorridor.minY * size.height + outerCornerSize.width / 2.0)
                node.addChild(westOuterCorner)
                
                // Fill the gap between the inner wall and south corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minX + cellOffset)..<Int(southCorridor.minX) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let southOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                southOuterCorner.position = CGPoint(x: southCorridor.minX * size.width + outerCornerSize.width / 2.0,
                                                    y: room.roomRect.minY * size.height + outerCornerSize.height / 2.0)
                node.addChild(southOuterCorner)
            }
        } else if let westCorridor = room.westCorridorRect {
            if westCorridor.minY == room.roomRect.minY {
                // There is no south corridor and the west corridor is on room boundaries, do not add inner
                // or outer walls, add walls to the south edge
                for i in Int(room.roomRect.minX)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no south corridor and the west corridor is not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi / 2.0)
                innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.height / 2.0,
                                               y: room.roomRect.minY * size.height + innerCornerSize.width / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and west corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minY + cellOffset)..<Int(westCorridor.minY) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let westOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                westOuterCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.height / 2.0,
                                                   y: westCorridor.minY * size.height + outerCornerSize.width / 2.0)
                node.addChild(westOuterCorner)
                
                // Fill the south edge with walls
                for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
            }
        } else if let southCorridor = room.southCorridorRect {
            if southCorridor.minX == room.roomRect.minX {
                // There is no west corridor and the south corridor is on the room boundaries, do not add inner
                // or outer walls, west edge will be filled when computing the top left corner, only fill the
                // west edge area that would be covered if there was an inner wall
                for i in Int(room.roomRect.minY)..<Int(room.roomRect.minY + cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no west corridor and the south corridor in not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi / 2.0)
                innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.height / 2.0,
                                               y: room.roomRect.minY * size.height + innerCornerSize.width / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and south corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minX + cellOffset)..<Int(southCorridor.minX) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let southOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi / 2.0)
                southOuterCorner.position = CGPoint(x: southCorridor.minX * size.width + outerCornerSize.width / 2.0,
                                                    y: room.roomRect.minY * size.height + outerCornerSize.height / 2.0)
                node.addChild(southOuterCorner)
                
                // The west edge will be filled when computing the top left corner
            }
        }
        
        ////////////////////////////////////////////////////////////////
        // From bottom right corner
        //
        if room.eastCorridorRect == nil && room.southCorridorRect == nil {
            // Add inner wall to (maxX, minY)
            let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi)
            innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.width / 2.0,
                                           y: room.roomRect.minY * size.height + innerCornerSize.height / 2.0)
            node.addChild(innerCorner)
            
            // Fill east edge with walls
            for i in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY - cellOffset) {
                let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                        y: CGFloat(i) * size.height + wallSize.width / 2.0)
                node.addChild(wall)
            }
        } else if let eastCorridor = room.eastCorridorRect, let southCorridor = room.southCorridorRect {
            if eastCorridor.minY == room.roomRect.minY || southCorridor.maxX == room.roomRect.maxX {
                // No inner wall
                if eastCorridor.minY == room.roomRect.minY && southCorridor.maxX == room.roomRect.maxX {
                    // Both corridors are on the room boundaries, just add an outer corner
                    let outerCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                    outerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: room.roomRect.minY * size.height + outerCornerSize.width / 2.0)
                    node.addChild(outerCorner)
                } else if eastCorridor.minY == room.roomRect.minY {
                    // Only east corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(southCorridor.maxX)..<Int(room.roomRect.maxX) {
                        let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                        wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                                y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                    outerCorner.position = CGPoint(x: (southCorridor.maxX - cellOffset) * size.width + outerCornerSize.width / 2.0,
                                                   y: room.roomRect.minY * size.height + outerCornerSize.height / 2.0)
                    node.addChild(outerCorner)
                } else if southCorridor.maxX == room.roomRect.maxX {
                    // Only south corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(room.roomRect.minY)..<Int(eastCorridor.minY) {
                        let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                        wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                                y: CGFloat(i) * size.height + wallSize.width / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                    outerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: eastCorridor.minY * size.height + outerCornerSize.width / 2.0)
                    node.addChild(outerCorner)
                }
            } else {
                // None of the corridors are on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi)
                innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.width / 2.0,
                                               y: room.roomRect.minY * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and east corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minY + cellOffset)..<Int(eastCorridor.minY) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let eastOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                eastOuterCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.width / 2.0,
                                                   y: eastCorridor.minY * size.height + outerCornerSize.height / 2.0)
                node.addChild(eastOuterCorner)
                
                // Fill the gap between the inner wall and south corridor, adding an outer wall at the end
                for i in Int(southCorridor.maxX)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let southOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                southOuterCorner.position = CGPoint(x: (southCorridor.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                    y: room.roomRect.minY * size.height + outerCornerSize.width / 2.0)
                node.addChild(southOuterCorner)
            }
        } else if let eastCorridor = room.eastCorridorRect {
            if eastCorridor.minY == room.roomRect.minY {
                // There is no south corridor and the east corridor is on the room boundaries, do not add inner
                // or outer walls, south edge was filled when computing the bottom left corner, only fill the
                // south edge area that would be covered if there was an inner wall
                for i in Int(room.roomRect.maxX - cellOffset)..<Int(room.roomRect.maxX) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no south corridor and the east corridor is not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi)
                innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.width / 2.0,
                                               y: room.roomRect.minY * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and east corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minY + cellOffset)..<Int(eastCorridor.minY) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let eastOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                eastOuterCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.width / 2.0,
                                                   y: eastCorridor.minY * size.height + outerCornerSize.height / 2.0)
                node.addChild(eastOuterCorner)
                
                // South edge already filled
            }
        } else if let southCorridor = room.southCorridorRect {
            if southCorridor.maxX == room.roomRect.maxX {
                // There is no east corridor and the south corridor is not on the room boundaries, do not add inner
                // or outer walls, add walls to the east edge
                for i in Int(room.roomRect.minY)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no east corridor and the south corridor in not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: CGFloat.pi)
                innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.width / 2.0,
                                               y: room.roomRect.minY * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and south corridor, adding an outer wall at the end
                for i in Int(southCorridor.maxX)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: room.roomRect.minY * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let southOuterCorner = tileSet.makeOuterCorner(zRotation: CGFloat.pi)
                southOuterCorner.position = CGPoint(x: (southCorridor.maxX - cellOffset) * size.width + outerCornerSize.width / 2.0,
                                                    y: room.roomRect.minY * size.height + outerCornerSize.height / 2.0)
                node.addChild(southOuterCorner)
                
                // Fill the east edge with walls
                for i in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
            }
        }
        
        ////////////////////////////////////////////////////////////////
        // From top right corner
        //
        if room.eastCorridorRect == nil && room.northCorridorRect == nil {
            // Add inner wall to (maxX, maxY)
            let innerCorner = tileSet.makeInnerCorner(zRotation: -CGFloat.pi / 2.0)
            innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.height / 2.0,
                                           y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.width / 2.0)
            node.addChild(innerCorner)
            
            // Fill north edge with walls
            for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX - cellOffset) {
                let wall = tileSet.makeWall(zRotation: 0)
                wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                        y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                node.addChild(wall)
            }
        } else if let eastCorridor = room.eastCorridorRect, let northCorridor = room.northCorridorRect {
            if eastCorridor.maxY == room.roomRect.maxY || northCorridor.maxX == room.roomRect.maxX {
                // No inner wall
                if eastCorridor.maxY == room.roomRect.maxY && northCorridor.maxX == room.roomRect.maxX {
                    // Both corridors are on the room boundaries, just add an outer corner
                    let outerCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                    outerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                    node.addChild(outerCorner)
                } else if eastCorridor.maxY == room.roomRect.maxY {
                    // Only east corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(northCorridor.maxX)..<Int(room.roomRect.maxX) {
                        let wall = tileSet.makeWall(zRotation: 0)
                        wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                                y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                    outerCorner.position = CGPoint(x: (northCorridor.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                    node.addChild(outerCorner)
                } else if northCorridor.maxX == room.roomRect.maxX {
                    // Only north corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(eastCorridor.maxY)..<Int(room.roomRect.maxY) {
                        let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                        wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                                y: CGFloat(i) * size.height + wallSize.width / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                    outerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: (eastCorridor.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                    node.addChild(outerCorner)
                }
            } else {
                // None of the corridors are on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: -CGFloat.pi / 2.0)
                innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.height / 2.0,
                                               y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.width / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and east corridor, adding an outer wall at the end
                for i in Int(eastCorridor.maxY)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let eastOuterCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                eastOuterCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: (eastCorridor.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                node.addChild(eastOuterCorner)
                
                // Fill the gap between the inner wall and north corridor, adding an outer wall at the end
                for i in Int(northCorridor.maxX)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let northOuterCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                northOuterCorner.position = CGPoint(x: (northCorridor.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                    y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                node.addChild(northOuterCorner)
            }
        } else if let eastCorridor = room.eastCorridorRect {
            if eastCorridor.maxY == room.roomRect.maxY {
                // There is no north corridor and the east corridor is on the room boundaries, do not add inner
                // or outer walls, add walls to the north edge
                for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no north corridor and the east corridor is not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: -CGFloat.pi / 2.0)
                innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.height / 2.0,
                                               y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.width / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and east corridor, adding an outer wall at the end
                for i in Int(eastCorridor.maxY)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let eastOuterCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                eastOuterCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                   y: (eastCorridor.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                node.addChild(eastOuterCorner)
                
                // Fill the north edge with walls
                for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
            }
        } else if let northCorridor = room.northCorridorRect {
            if northCorridor.maxX == room.roomRect.maxX {
                // There is no east corridor and the north corridor is on the room boundaries, do not add inner
                // or outer walls, east edge was filled when computing the bottom right corner, only fill the
                // east edge area that would be covered if there was an inner wall
                for i in Int(room.roomRect.maxY - cellOffset)..<Int(room.roomRect.maxY) {
                    let wall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no east corridor and the north corridor in not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: -CGFloat.pi / 2.0)
                innerCorner.position = CGPoint(x: (room.roomRect.maxX - cellOffset) * size.width + innerCornerSize.height / 2.0,
                                               y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.width / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and north corridor, adding an outer wall at the end
                for i in Int(northCorridor.maxX)..<Int(room.roomRect.maxX - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let northOuterCorner = tileSet.makeOuterCorner(zRotation: -CGFloat.pi / 2.0)
                northOuterCorner.position = CGPoint(x: (northCorridor.maxX - cellOffset) * size.width + outerCornerSize.height / 2.0,
                                                    y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                node.addChild(northOuterCorner)
                
                // East edge already filled
            }
        }
        
        ////////////////////////////////////////////////////////////////
        // From top left corner
        //
        if room.westCorridorRect == nil && room.northCorridorRect == nil {
            // Add inner wall to (minX, maxY)
            let innerCorner = tileSet.makeInnerCorner(zRotation: 0)
            innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.width / 2.0,
                                           y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.height / 2.0)
            node.addChild(innerCorner)
            
            // Fill the west edge with walls
            for i in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY - cellOffset) {
                let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                        y: CGFloat(i) * size.height + wallSize.width / 2.0)
                node.addChild(wall)
            }
        } else if let westCorridor = room.westCorridorRect, let northCorridor = room.northCorridorRect {
            if westCorridor.maxY == room.roomRect.maxY || northCorridor.minX == room.roomRect.minX {
                // No inner wall
                if  westCorridor.maxY == room.roomRect.maxY && northCorridor.minX == room.roomRect.minX  {
                    // Both corridors are on the room boundaries, just add an outer corner
                    let outerCorner = tileSet.makeOuterCorner(zRotation: 0)
                    outerCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.height / 2.0)
                    node.addChild(outerCorner)
                } else if westCorridor.maxY == room.roomRect.maxY {
                    // Only west corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(room.roomRect.minX)..<Int(northCorridor.minX) {
                        let wall = tileSet.makeWall(zRotation: 0)
                        wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                                y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: 0)
                    outerCorner.position = CGPoint(x: northCorridor.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.height / 2.0)
                    node.addChild(outerCorner)
                } else if northCorridor.minX == room.roomRect.minX {
                    // Only north corridor is on the room boundaries, fill the gap with walls and add outer corner
                    for i in Int(westCorridor.maxY)..<Int(room.roomRect.maxY) {
                        let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                        wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                                y: CGFloat(i) * size.height + wallSize.width / 2.0)
                        node.addChild(wall)
                    }
                    let outerCorner = tileSet.makeOuterCorner(zRotation: 0)
                    outerCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: (westCorridor.maxY - cellOffset) * size.height + outerCornerSize.height / 2.0)
                    node.addChild(outerCorner)
                }
            } else {
                // None of the corridors are on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: 0)
                innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.width / 2.0,
                                               y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and west corridor, adding an outer wall at the end
                for i in Int(westCorridor.maxY)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let westOuterCorner = tileSet.makeOuterCorner(zRotation: 0)
                westOuterCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: (westCorridor.maxY - cellOffset) * size.height + outerCornerSize.height / 2.0)
                node.addChild(westOuterCorner)
                
                // Fill the gap between the inner wall and north corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minX + cellOffset)..<Int(northCorridor.minX) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let northOuterCorner = tileSet.makeOuterCorner(zRotation: 0)
                northOuterCorner.position = CGPoint(x: northCorridor.minX * size.width + outerCornerSize.height / 2.0,
                                                    y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.width / 2.0)
                node.addChild(northOuterCorner)
            }
        } else if let westCorridor = room.westCorridorRect {
            if westCorridor.maxY == room.roomRect.maxY {
                // There is no north corridor and the west corridor is on the room boundaries, do not add inner
                // or outer walls, north edge was filled when computing the top right corner, only fill the
                // north edge area that would be covered if there was an inner wall
                for i in Int(room.roomRect.minX)..<Int(room.roomRect.minX + cellOffset) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no north corridor and the west corridor in not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: 0)
                innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.width / 2.0,
                                               y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and west corridor, adding an outer wall at the end
                for i in Int(westCorridor.maxY)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
                let westOuterCorner = tileSet.makeOuterCorner(zRotation: 0)
                westOuterCorner.position = CGPoint(x: room.roomRect.minX * size.width + outerCornerSize.width / 2.0,
                                                   y: (westCorridor.maxY - cellOffset) * size.height + outerCornerSize.height / 2.0)
                node.addChild(westOuterCorner)
                
                // North edge already filled
            }
        } else if let northCorridor = room.northCorridorRect {
            if northCorridor.minX == room.roomRect.minX {
                // There is no west corridor and the north corridor is on the room boundaries, do not add inner
                // or outer walls, add walls to the west edge
                for i in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
            } else {
                // There is no west corridor and the north corridor is not on the room rect boundaries, add inner wall
                let innerCorner = tileSet.makeInnerCorner(zRotation: 0)
                innerCorner.position = CGPoint(x: room.roomRect.minX * size.width + innerCornerSize.width / 2.0,
                                               y: (room.roomRect.maxY - cellOffset) * size.height + innerCornerSize.height / 2.0)
                node.addChild(innerCorner)
                
                // Fill the gap between the inner wall and north corridor, adding an outer wall at the end
                for i in Int(room.roomRect.minX + cellOffset)..<Int(northCorridor.minX) {
                    let wall = tileSet.makeWall(zRotation: 0)
                    wall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                            y: (room.roomRect.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                    node.addChild(wall)
                }
                let northOuterCorner = tileSet.makeOuterCorner(zRotation: 0)
                northOuterCorner.position = CGPoint(x: northCorridor.minX * size.width + outerCornerSize.width / 2.0,
                                                    y: (room.roomRect.maxY - cellOffset) * size.height + outerCornerSize.height / 2.0)
                node.addChild(northOuterCorner)
                
                // Fill the west edge with walls
                for i in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY - cellOffset) {
                    let wall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                    wall.position = CGPoint(x: room.roomRect.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                    node.addChild(wall)
                }
            }
        }
        
        
        ////////////////////////////////////////////////////////////////
        // Done setting the walls/corners of the main room, now the center of the room have to be filled
        // with floor tiles - the area between the room and its corridors will be filled when computing
        // the corridors themselves, below
        //
        for i in Int(room.roomRect.minX + cellOffset)..<Int(room.roomRect.maxX - cellOffset) {
            for j in Int(room.roomRect.minY + cellOffset)..<Int(room.roomRect.maxY - cellOffset) {
                let floor = tileSet.makeFloor(zRotation: 0)
                floor.position = CGPoint(x: CGFloat(i) * size.width + floorSize.width / 2.0,
                                         y: CGFloat(j) * size.width + floorSize.height / 2.0)
                node.addChild(floor)
            }
        }
        
        
        ////////////////////////////////////////////////////////////////
        // Done filling the main room walls/corners/floors, now the corridors walls can be trivially filled
        // with just common walls, since the corners were already set when computing the room rect walls above
        // The corridor interior and the area connecting room and corridor will be filled with floor tiles
        //
        if let northCorridor = room.northCorridorRect {
            for i in Int(northCorridor.minY)..<Int(northCorridor.maxY) {
                // Add the walls
                let westWall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                westWall.position = CGPoint(x: northCorridor.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                let eastWall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                eastWall.position = CGPoint(x: (northCorridor.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                node.addChild(westWall)
                node.addChild(eastWall)
                
                // Add the floor
                for j in Int(northCorridor.minX + cellOffset)..<Int(northCorridor.maxX - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(j) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(i) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
            // Add the floor to the room area that connects with this corridor
            for i in Int(northCorridor.minY - cellOffset)..<Int(northCorridor.minY) {
                for j in Int(northCorridor.minX + cellOffset)..<Int(northCorridor.maxX - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(j) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(i) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
        }
        if let southCorridor = room.southCorridorRect {
            for i in Int(southCorridor.minY)..<Int(southCorridor.maxY) {
                // Add the walls
                let westWall = tileSet.makeWall(zRotation: CGFloat.pi / 2.0)
                westWall.position = CGPoint(x: southCorridor.minX * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                let eastWall = tileSet.makeWall(zRotation: -CGFloat.pi / 2.0)
                eastWall.position = CGPoint(x: (southCorridor.maxX - cellOffset) * size.width + wallSize.height / 2.0,
                                            y: CGFloat(i) * size.height + wallSize.width / 2.0)
                node.addChild(westWall)
                node.addChild(eastWall)
                
                // Add the floor
                for j in Int(southCorridor.minX + cellOffset)..<Int(southCorridor.maxX - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(j) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(i) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
            // Add the floor to the room area that connects with this corridor
            for i in Int(southCorridor.maxY)..<Int(southCorridor.maxY + cellOffset) {
                for j in Int(southCorridor.minX + cellOffset)..<Int(southCorridor.maxX - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(j) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(i) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
        }
        if let eastCorridor = room.eastCorridorRect {
            for i in Int(eastCorridor.minX)..<Int(eastCorridor.maxX) {
                // Add the walls
                let southWall = tileSet.makeWall(zRotation: CGFloat.pi)
                southWall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                             y: eastCorridor.minY * size.height + wallSize.height / 2.0)
                let northWall = tileSet.makeWall(zRotation: 0)
                northWall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                             y: (eastCorridor.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                node.addChild(southWall)
                node.addChild(northWall)
                
                // Add the floor
                for j in Int(eastCorridor.minY + cellOffset)..<Int(eastCorridor.maxY - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(i) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(j) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
            // Add the floor to the room area that connects with this corridor
            for i in Int(eastCorridor.minX - cellOffset)..<Int(eastCorridor.minX) {
                for j in Int(eastCorridor.minY + cellOffset)..<Int(eastCorridor.maxY - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(i) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(j) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
        }
        if let westCorridor = room.westCorridorRect {
            for i in Int(westCorridor.minX)..<Int(westCorridor.maxX) {
                // Add the walls
                let southWall = tileSet.makeWall(zRotation: CGFloat.pi)
                southWall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                             y: westCorridor.minY * size.height + wallSize.height / 2.0)
                let northWall = tileSet.makeWall(zRotation: 0)
                northWall.position = CGPoint(x: CGFloat(i) * size.width + wallSize.width / 2.0,
                                             y: (westCorridor.maxY - cellOffset) * size.height + wallSize.height / 2.0)
                node.addChild(southWall)
                node.addChild(northWall)
                
                // Add the floor
                for j in Int(westCorridor.minY + cellOffset)..<Int(westCorridor.maxY - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(i) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(j) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
            // Add the floor to the room area that connects with this corridor
            for i in Int(westCorridor.maxX)..<Int(westCorridor.maxX + cellOffset) {
                for j in Int(westCorridor.minY + cellOffset)..<Int(westCorridor.maxY - cellOffset) {
                    let floor = tileSet.makeFloor(zRotation: 0)
                    floor.position = CGPoint(x: CGFloat(i) * size.width + floorSize.width / 2.0,
                                             y: CGFloat(j) * size.height + floorSize.height / 2.0)
                    node.addChild(floor)
                }
            }
        }
        
    }
}

