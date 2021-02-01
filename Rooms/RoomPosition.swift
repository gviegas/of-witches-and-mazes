//
//  RoomPosition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that represents the valid position inside a `Room`.
///
/// Valid positions are expected to be points in a room where content can be placed,
/// i.e., not walls nor corners, only floor.
///
class RoomPosition {
    
    /// The valid positions in the main room.
    ///
    let roomPositions: [CGPoint]
    
    /// The valid positions in the north corridor.
    ///
    let northCorridorPositions: [CGPoint]?
    
    /// The valid positions in the south corridor.
    ///
    let southCorridorPositions: [CGPoint]?
    
    /// The valid positions in the east corridor.
    ///
    let eastCorridorPositions: [CGPoint]?
    
    /// The valid positions in the west corridor.
    ///
    let westCorridorPositions: [CGPoint]?
    
    /// Creates a new instance from the given position arrays.
    ///
    /// - Parameters:
    ///   - roomPositions: An array containing the positions of the main room.
    ///   - northCorridorPositions: An optional array containing the positions of the north corridor.
    ///     The default value is `nil`.
    ///   - southCorridorPositions: An optional array containing the positions of the south corridor.
    ///     The default value is `nil`.
    ///   - eastCorridorPositions: An optional array containing the positions of the east corridor.
    ///     The default value is `nil`.
    ///   - westCorridorPositions: An optional array containing the positions of the west corridor.
    ///     The default value is `nil`.
    ///
    init(roomPositions: [CGPoint], northCorridorPositions: [CGPoint]? = nil,
         southCorridorPositions: [CGPoint]? = nil, eastCorridorPositions: [CGPoint]? = nil,
         westCorridorPositions: [CGPoint]? = nil) {
        
        self.roomPositions = roomPositions
        self.northCorridorPositions = northCorridorPositions
        self.southCorridorPositions = southCorridorPositions
        self.eastCorridorPositions = eastCorridorPositions
        self.westCorridorPositions = westCorridorPositions
    }
}
