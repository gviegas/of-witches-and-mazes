//
//  RandomRoomCreator.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `RoomCreator` type that creates random rooms.
///
class RandomRoomCreator: RoomCreator {
    
    var rect: CGRect
    
    /// - Note: The connection properties should be set as needed before calling `makeRoom()`.
    ///
    var northConnection = false
    var southConnection = false
    var eastConnection = false
    var westConnection = false
    var northConnectionXAndLength: (x: Int, length: Int)?
    var southConnectionXAndLength: (x: Int, length: Int)?
    var eastConnectionYAndLength: (y: Int, length: Int)?
    var westConnectionYAndLength: (y: Int, length: Int)?
    
    /// The minimum size of the room.
    ///
    var minSize: CGSize
    
    /// The maximum size of the room
    ///
    var maxSize: CGSize
    
    /// The deadzone between a connection and the room rect adjacent corners, i.e., the minimum
    /// distance from any of the rect's adjacent edges and a connection that is not exactly aligned
    /// (e.g., a north connection `minX` is equal to the rect's `minX` or at least `rect.minX` + `cornerGap`
    /// units away).
    ///
    var cornerGap: CGSize
    
    /// Creates a new instance from the given values
    ///
    /// - Parameters:
    ///   - rect: The boundaries of the room to create.
    ///   - minSize: The minimum size of created rooms.
    ///   - maxSize: The maximum size of created rooms.
    ///   - cornerGap: An offset to account for corners that are larger than one unit in size.
    ///
    init(rect: CGRect, minSize: CGSize, maxSize: CGSize, cornerGap: CGSize = CGSize.zero) {
        self.rect = rect
        self.minSize = minSize
        self.maxSize = maxSize
        self.cornerGap = cornerGap
    }
    
    /// Creates a new random room using the current property values.
    ///
    /// This method is intended to be called with no more than one predefined connection,
    /// otherwise it may fail (it almost always fails when cornerGap is larger than one unit,
    /// since gap correction will eventually grow the room rect beyond the rect boundaries).
    /// Also, it is expected that the following holds true:
    ///
    ///     0 <= cornerGap < minSize <= maxSize <= rect.size
    ///
    /// - Returns: A `Room` instance of random dimensions.
    ///
    func makeRoom() -> Room {
        
        // The x coordinates that the room rect must cover to align with the horizontal connections
        var x: (min: Int, max: Int)?
        
        // Set the x coordinates if needed
        if northConnection, let conn = northConnectionXAndLength {
            x = (conn.x, conn.x + conn.length)
        }
        if southConnection, let conn = southConnectionXAndLength {
            if x != nil {
                if conn.x < x!.min {
                    let gap = x!.min - conn.x
                    x!.min -= (gap < Int(cornerGap.width)) ? Int(cornerGap.width) + gap : gap
                }
                if (conn.x + conn.length) > x!.max {
                    let gap = conn.x + conn.length - x!.max
                    x!.max += (gap < Int(cornerGap.width)) ? Int(cornerGap.width) + gap : gap
                }
            } else {
                x = (conn.x, conn.x + conn.length)
            }
        }
        
        // The y coordinates that the room rect must cover to align with the vertical connections
        var y: (min: Int, max: Int)?
        
        // Set the y coordinates if needed
        if eastConnection, let conn = eastConnectionYAndLength {
            y = (conn.y, conn.y + conn.length)
        }
        if westConnection, let conn = westConnectionYAndLength {
            if y != nil {
                if conn.y < y!.min {
                    let gap = y!.min - conn.y
                    y!.min -= (gap < Int(cornerGap.height)) ? Int(cornerGap.height) + gap : gap
                }
                if (conn.y + conn.length) > y!.max {
                    let gap = conn.y + conn.length - y!.max
                    y!.max += (gap < Int(cornerGap.height)) ? Int(cornerGap.height) + gap : gap
                }
            } else {
                y = (conn.y, conn.y + conn.length)
            }
        }
        
        // Check if complying with any given connection did not break any boundaries
        if let x = x, x.min < Int(rect.minX) || x.max > Int(rect.maxX) || x.max - x.min > Int(maxSize.width) {
            fatalError("Complying with a horizontal connection was not possible")
        }
        if let y = y, y.min < Int(rect.minY) || y.max > Int(rect.maxY) || y.max - y.min > Int(maxSize.height) {
            fatalError("Complying with a vertical connection was not possible")
        }
        
        // At this point, x and y, if set to non-nil values, define the coordinates of a subrect that
        // the final room rect must align with - now, create the room rect
        var roomRect = CGRect.zero
        
        if x != nil {
            // Have to align with the subrect on the x axis
            if (x!.max - x!.min) < Int(minSize.width) {
                // The subrect is too small, grow it horizontally
                var offsetRnd = Int.random(in: 0...(Int(minSize.width) - (x!.max - x!.min)))
                
                if (x!.min - offsetRnd) < Int(rect.minX) {
                    offsetRnd = x!.min - Int(rect.minX)
                }
                if (x!.min - offsetRnd) < Int(cornerGap.width) {
                    offsetRnd = 0
                }
                
                x!.min -= offsetRnd
                x!.max += Int(minSize.width) - (x!.max - x!.min)
                
                // If x.max grew larger than the boundary rect maxX, it means that the specified connection
                // and the minimum size width are not compatible with each other
                guard x!.max <= Int(rect.maxX) else {
                    fatalError("Failed to create a room rect inside the specified boundaries")
                }
            }
            
            // Set the origin's x for the room rect
            let minOffset = (x!.max - Int(rect.minX) <= Int(maxSize.width)) ?
                (x!.min - Int(rect.minX)) : (Int(maxSize.width) - (x!.max - x!.min))
            var minRnd = Int.random(in: 0...minOffset)
            
            if (minRnd != 0) && (minRnd < Int(cornerGap.width)) {
                // This will tend towards larger main rooms with smaller corridors
                minRnd = (Int(cornerGap.width) <= minOffset) ? Int(cornerGap.width) : 0
            }
            
            roomRect.origin.x = CGFloat(x!.min - minRnd)
            
            // Set the width of the room rect
            let maxOffset = (rect.maxX - roomRect.minX <= maxSize.width) ?
                (Int(rect.maxX) - x!.max) : (Int(maxSize.width) - (x!.max - Int(roomRect.minX)))
            var maxRnd = Int.random(in: 0...maxOffset)
            
            if (maxRnd != 0) && (maxRnd < Int(cornerGap.width)) {
                // This will tend towards larger main rooms with smaller corridors
                maxRnd = (Int(cornerGap.width) <= maxOffset) ? Int(cornerGap.width) : 0
            }
            
            roomRect.size.width = CGFloat(x!.max + maxRnd) - roomRect.minX
            
            // Sanity check
            assert(rect.minX <= roomRect.minX && rect.maxX >= roomRect.maxX)
            
        } else {
            // No subrect to align with
            let lenRnd = Int.random(in: 0...(Int(maxSize.width - minSize.width)))
            roomRect.size.width = minSize.width + CGFloat(lenRnd)
            let minRnd = Int.random(in: 0...(Int(maxSize.width - roomRect.size.width)))
            roomRect.origin.x = rect.minX + CGFloat(minRnd)
        }
        
        if y != nil {
            // Have to align with the subrect on the y axis
            if (y!.max - y!.min) < Int(minSize.height) {
                // The subrect is too small, grow it vertically
                var offsetRnd = Int.random(in: 0...(Int(minSize.height) - (y!.max - y!.min)))
                
                if (y!.min - offsetRnd) < Int(rect.minY) {
                    offsetRnd = y!.min - Int(rect.minY)
                }
                if (y!.min - offsetRnd) < Int(cornerGap.height) {
                    offsetRnd = 0
                }
                
                y!.min -= offsetRnd
                y!.max += Int(minSize.height) - (y!.max - y!.min)
                
                // If y.max grew larger than the boundary rect maxY, it means that the specified connection
                // and the minimum size height are not compatible with each other
                guard y!.max <= Int(rect.maxY) else {
                    fatalError("Failed to create a room rect inside the specified boundaries")
                }
            }
            
            // Set the origin's y for the room rect
            let minOffset = (y!.max - Int(rect.minY) <= Int(maxSize.height)) ?
                (y!.min - Int(rect.minY)) : (Int(maxSize.height) - (y!.max - y!.min))
            var minRnd = Int.random(in: 0...minOffset)
            
            if (minRnd != 0) && (minRnd < Int(cornerGap.height)) {
                // This will tend towards larger main rooms with smaller corridors
                minRnd = (Int(cornerGap.height) <= minOffset) ? Int(cornerGap.height) : 0
            }
            
            roomRect.origin.y = CGFloat(y!.min - minRnd)
            
            // Set the height of the room rect
            let maxOffset = (rect.maxY - roomRect.minY <= maxSize.height) ?
                (Int(rect.maxY) - y!.max) : (Int(maxSize.height) - (y!.max - Int(roomRect.minY)))
            var maxRnd = Int.random(in: 0...maxOffset)
            
            if (maxRnd != 0) && (maxRnd < Int(cornerGap.height)) {
                // This will tend towards larger main rooms with smaller corridors
                maxRnd = (Int(cornerGap.height) <= maxOffset) ? Int(cornerGap.height) : 0
            }
            
            roomRect.size.height = CGFloat(y!.max + maxRnd) - roomRect.minY
            
            // Sanity check
            assert(rect.minY <= roomRect.minY && rect.maxY >= roomRect.maxY)
            
        } else {
            // No subrect to align with
            let lenRnd = Int.random(in: 0...(Int(maxSize.height - minSize.height)))
            roomRect.size.height = minSize.height + CGFloat(lenRnd)
            let minRnd = Int.random(in: 0...(Int(maxSize.height - roomRect.size.height)))
            roomRect.origin.y = rect.minY + CGFloat(minRnd)
        }
        
        // With the main room rect defined, the corridor rects can be created
        var northCorridorRect: CGRect?
        var southCorridorRect: CGRect?
        var eastCorridorRect: CGRect?
        var westCorridorRect: CGRect?
        
        if northConnection {
            // Create north corridor
            var corridor = CGRect.zero
            if let conn = northConnectionXAndLength {
                corridor.origin.x = CGFloat(conn.x)
                corridor.size.width = CGFloat(conn.length)
            } else {
                // Set the origin of this corridor
                var offset = Int.random(in: 0...(Int(roomRect.width - minSize.width)))
                if (offset != 0) && (offset < Int(cornerGap.width)) {
                    if cornerGap.width <= roomRect.width - minSize.width {
                        offset = Bool.random() ? Int(cornerGap.width) : 0
                    } else {
                        offset = 0
                    }
                }
                corridor.origin.x = roomRect.origin.x + CGFloat(offset)
                // Set the length of this corridor
                let fOffset = CGFloat(Int.random(in: 0...Int(roomRect.maxX - corridor.minX - minSize.width)))
                var len = minSize.width + fOffset
                if (corridor.minX + len != roomRect.maxX) &&
                    (roomRect.maxX - (corridor.minX + len) < cornerGap.width) {
                    
                    if roomRect.maxX - corridor.minX - cornerGap.width >= minSize.width {
                        len = Bool.random() ?
                            (roomRect.maxX - corridor.minX - cornerGap.width) :
                            (roomRect.maxX - corridor.minX)
                    } else {
                        len = roomRect.maxX - corridor.minX
                    }
                }
                corridor.size.width = len
            }
            corridor.origin.y = roomRect.maxY
            corridor.size.height = rect.maxY - roomRect.maxY
            northCorridorRect = corridor
        }
        
        if southConnection {
            // Create south corridor
            var corridor = CGRect.zero
            if let conn = southConnectionXAndLength {
                corridor.origin.x = CGFloat(conn.x)
                corridor.size.width = CGFloat(conn.length)
            } else {
                // Set the origin of this corridor
                var offset = Int.random(in: 0...(Int(roomRect.width - minSize.width)))
                if (offset != 0) && (offset < Int(cornerGap.width)) {
                    if cornerGap.width <= roomRect.width - minSize.width {
                        offset = Bool.random() ? Int(cornerGap.width) : 0
                    } else {
                        offset = 0
                    }
                }
                corridor.origin.x = roomRect.origin.x + CGFloat(offset)
                // Set the length of this corridor
                let fOffset = CGFloat(Int.random(in: 0...Int(roomRect.maxX - corridor.minX - minSize.width)))
                var len = minSize.width + fOffset
                if (corridor.minX + len != roomRect.maxX) &&
                    (roomRect.maxX - (corridor.minX + len) < cornerGap.width) {
                    
                    if roomRect.maxX - corridor.minX - cornerGap.width >= minSize.width {
                        len = Bool.random() ?
                            (roomRect.maxX - corridor.minX - cornerGap.width) :
                            (roomRect.maxX - corridor.minX)
                    } else {
                        len = roomRect.maxX - corridor.minX
                    }
                }
                corridor.size.width = len
            }
            corridor.origin.y = rect.minY
            corridor.size.height = roomRect.minY - rect.minY
            southCorridorRect = corridor
        }
        
        if eastConnection {
            // Create east corridor
            var corridor = CGRect.zero
            if let conn = eastConnectionYAndLength {
                corridor.origin.y = CGFloat(conn.y)
                corridor.size.height = CGFloat(conn.length)
            } else {
                // Set the origin of this corridor
                var offset = Int.random(in: 0...Int(roomRect.height - minSize.height))
                if (offset != 0) && (offset < Int(cornerGap.height)) {
                    if cornerGap.height <= roomRect.height - minSize.height {
                        offset = Bool.random() ? Int(cornerGap.height) : 0
                    } else {
                        offset = 0
                    }
                }
                corridor.origin.y = roomRect.origin.y + CGFloat(offset)
                // Set the length of this corridor
                let fOffset = CGFloat(Int.random(in: 0...Int(roomRect.maxY - corridor.minY - minSize.height)))
                var len = minSize.height + fOffset
                if (corridor.minY + len != roomRect.maxY) &&
                    (roomRect.maxY - (corridor.minY + len) < cornerGap.height) {
                    
                    if roomRect.maxY - corridor.minY - cornerGap.height >= minSize.height {
                        len = Bool.random() ?
                            (roomRect.maxY - corridor.minY - cornerGap.height) :
                            (roomRect.maxY - corridor.minY)
                    } else {
                        len = roomRect.maxY - corridor.minY
                    }
                }
                corridor.size.height = len
            }
            corridor.origin.x = roomRect.maxX
            corridor.size.width = rect.maxX - roomRect.maxX
            eastCorridorRect = corridor
        }
        
        if westConnection {
            // Create west corridor
            var corridor = CGRect.zero
            if let conn = westConnectionYAndLength {
                corridor.origin.y = CGFloat(conn.y)
                corridor.size.height = CGFloat(conn.length)
            } else {
                // Set the origin of this corridor
                var offset = Int.random(in: 0...Int(roomRect.height - minSize.height))
                if (offset != 0) && (offset < Int(cornerGap.height)) {
                    if cornerGap.height <= roomRect.height - minSize.height {
                        offset = Bool.random() ? Int(cornerGap.height) : 0
                    } else {
                        offset = 0
                    }
                }
                corridor.origin.y = roomRect.origin.y + CGFloat(offset)
                // Set the length of this corridor
                let fOffset = CGFloat(Int.random(in: 0...Int(roomRect.maxY - corridor.minY - minSize.height)))
                var len = minSize.height + fOffset
                if (corridor.minY + len != roomRect.maxY) &&
                    (roomRect.maxY - (corridor.minY + len) < cornerGap.height) {
                    
                    if roomRect.maxY - corridor.minY - cornerGap.height >= minSize.height {
                        len = Bool.random() ?
                            (roomRect.maxY - corridor.minY - cornerGap.height) :
                            (roomRect.maxY - corridor.minY)
                    } else {
                        len = roomRect.maxY - corridor.minY
                    }
                }
                corridor.size.height = len
            }
            corridor.origin.x = rect.minX
            corridor.size.width = roomRect.minX - rect.minX
            westCorridorRect = corridor
        }
        
        // Final sanity check to make sure the room rect is valid
        assert(rect.contains(roomRect), "Generated room rect falls outside the bounding rect\nboundary: \(rect)\nroom: \(roomRect)")
        
        return Room(roomRect: roomRect,
                    northCorridorRect: northCorridorRect,
                    southCorridorRect: southCorridorRect,
                    eastCorridorRect: eastCorridorRect,
                    westCorridorRect: westCorridorRect)
    }
}
