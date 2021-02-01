//
//  RoomObstacle.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/9/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that represents the obstacles of a `RoomArea`.
///
class RoomObstacle {
    
    /// The obstacles of the room area.
    ///
    let roomObstacles: [CGRect]
    
    /// The obstacles of the north corridor area.
    ///
    let northCorridorObstacles: [CGRect]?
    
    /// The obstacles of the south corridor area.
    ///
    let southCorridorObstacles: [CGRect]?
    
    /// The obstacles of the east corridor area.
    ///
    let eastCorridorObstacles: [CGRect]?
    
    /// The obstacles of the west corridor area.
    ///
    let westCorridorObstacles: [CGRect]?
    
    /// Creates a new instance from the given room area and contents.
    ///
    /// - Parameters:
    ///   - roomArea: The `RoomArea` instance from which the obstacles must be created.
    ///   - roomContents: The static contents of the room.
    ///   - cellSize: The cell size that was used when setting the room contents.
    ///
    init(roomArea: RoomArea, roomContents: [Content], cellSize: CGSize) {
        var room = [CGRect]()
        var northCorridor: [CGRect]? = roomArea.northCorridorArea != nil ? [CGRect]() : nil
        var southCorridor: [CGRect]? = roomArea.southCorridorArea != nil ? [CGRect]() : nil
        var eastCorridor: [CGRect]? = roomArea.eastCorridorArea != nil ? [CGRect]() : nil
        var westCorridor: [CGRect]? = roomArea.westCorridorArea != nil ? [CGRect]() : nil
        
        for content in roomContents where content.isObstacle {
            let position: CGPoint
            let size: CGSize
            if let physicsComponent = content.entity?.component(ofType: PhysicsComponent.self) {
                // The content has an entity with a PhysicsComponent - use its physics shape as obstacle
                position = CGPoint(x: physicsComponent.position.x / cellSize.width,
                                   y: physicsComponent.position.y / cellSize.height)
                switch physicsComponent.physicsShape {
                case .circle(let radius, _):
                    size = CGSize(width: radius * 2 / cellSize.width, height: radius * 2 / cellSize.height)
                case .rectangle(let sz, _):
                    size = CGSize(width: sz.width / cellSize.width, height: sz.height / cellSize.height)
                }
            } else {
                // The content is not an entity - use the content size and node position as obstacle
                position = CGPoint(x: content.node.position.x / cellSize.width,
                                   y: content.node.position.y / cellSize.height)
                size = CGSize(width: content.size.width / cellSize.width,
                              height: content.size.height / cellSize.height)
            }
            let obstacle = CGRect(x: position.x - size.width / 2.0, y: position.y - size.height / 2.0,
                                  width: size.width, height: size.height)
            
            if roomArea.roomArea.contains(position) {
                room.append(obstacle)
            } else if roomArea.northCorridorArea?.contains(position) ?? false {
                northCorridor!.append(obstacle)
            } else if roomArea.southCorridorArea?.contains(position) ?? false {
                southCorridor!.append(obstacle)
            } else if roomArea.eastCorridorArea?.contains(position) ?? false {
                eastCorridor!.append(obstacle)
            } else if roomArea.westCorridorArea?.contains(position) ?? false {
                westCorridor!.append(obstacle)
            } else {
                assert(false)
            }
        }
        
        roomObstacles = room
        northCorridorObstacles = northCorridor
        southCorridorObstacles = southCorridor
        eastCorridorObstacles = eastCorridor
        westCorridorObstacles = westCorridor
    }
}
