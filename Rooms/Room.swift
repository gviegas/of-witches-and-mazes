//
//  Room.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that represents a single room.
///
/// A `Room` is defined by a number of rects. A `roomRect` defines the main area of the room,
/// connected by up to four optional corridor rects: north, south, east and west.
///
class Room {
    
    /// The room rect.
    ///
    let roomRect: CGRect
    
    /// The north room corridor rect.
    ///
    let northCorridorRect: CGRect?
    
    /// The south room corridor rect.
    ///
    let southCorridorRect: CGRect?
    
    /// The east room corridor rect.
    ///
    let eastCorridorRect: CGRect?
    
    /// The west room corridor rect.
    ///
    let westCorridorRect: CGRect?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - roomRect: The rect that defines the main room.
    ///   - northCorridorRect: An optional rect that defines the north corridor. The default value is `nil`.
    ///   - southCorridorRect: An optional rect that defines the south corridor. The default value is `nil`.
    ///   - eastCorridorRect: An optional rect that defines the east corridor. The default value is `nil`.
    ///   - westCorridorRect: An optional rect that defines the west corridor. The default value is `nil`.
    ///
    init(roomRect: CGRect, northCorridorRect: CGRect? = nil, southCorridorRect: CGRect? = nil,
         eastCorridorRect: CGRect? = nil, westCorridorRect: CGRect? = nil) {
        
        self.roomRect = roomRect
        self.northCorridorRect = northCorridorRect
        self.southCorridorRect = southCorridorRect
        self.eastCorridorRect = eastCorridorRect
        self.westCorridorRect = westCorridorRect
    }
}
