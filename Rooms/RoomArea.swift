//
//  RoomArea.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that represents the valid areas of a `Room`.
///
/// Valid areas are expected to be subrects of a room where content can be placed,
/// i.e., not walls nor corners, only floor extent.
///
class RoomArea {
    
    /// The valid room area.
    ///
    let roomArea: CGRect
    
    /// The valid north corridor area.
    ///
    let northCorridorArea: CGRect?
    
    /// The valid south corridor area.
    ///
    let southCorridorArea: CGRect?
    
    /// The valid east corridor area.
    ///
    let eastCorridorArea: CGRect?
    
    /// The valid west corridor area.
    ///
    let westCorridorArea: CGRect?
    
    /// Creates a new instance from the given rects.
    ///
    /// - Parameters:
    ///   - roomArea: The rect defining the main room area.
    ///   - northCorridorArea: An optional rect defining the north corridor area. The default value is `nil`.
    ///   - southCorridorArea: An optional rect defining the south corridor area. The default value is `nil`.
    ///   - eastCorridorArea: An optional rect defining the east corridor area. The default value is `nil`.
    ///   - westCorridorArea: An optional rect defining the west corridor area. The default value is `nil`.
    ///
    init(roomArea: CGRect, northCorridorArea: CGRect? = nil, southCorridorArea: CGRect? = nil,
         eastCorridorArea: CGRect? = nil, westCorridorArea: CGRect? = nil) {
        
        self.roomArea = roomArea
        self.northCorridorArea = northCorridorArea
        self.southCorridorArea = southCorridorArea
        self.eastCorridorArea = eastCorridorArea
        self.westCorridorArea = westCorridorArea
    }
}
