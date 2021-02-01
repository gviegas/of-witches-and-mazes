//
//  RoomCreator.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that `Room` factories must conform to.
///
/// Note that the rooms created by this creators are not intended to be given in pixels (or points).
/// Usually, a game specific unit (e.g. a tile) should be used. So, for example, a boundary rect of
/// size 10x10 could be interpreted as a 100 tiles quad. Overall, that makes the rooms easier to
/// manage for different dimensions.
///
protocol RoomCreator: AnyObject {
    
    /// The boundaries of the room.
    ///
    var rect: CGRect { get set }
    
    /// A flag indicating if a north connection must be created.
    ///
    var northConnection: Bool { get set }
    
    /// A flag indicating if a south connection must be created.
    ///
    var southConnection: Bool { get set }
    
    /// A flag indicating if an east connection must be created.
    ///
    var eastConnection: Bool { get set }
    
    /// A flag indicating if a west connection must be created.
    ///
    var westConnection: Bool { get set }
    
    /// A pair consisting of the x (horizontal) coordinate on which a north connection must have its origin,
    /// and the length that this connection must have on the horizontal axis.
    ///
    var northConnectionXAndLength: (x: Int, length: Int)? { get set }
    
    /// A pair consisting of the x (horizontal) coordinate on which a south connection must have its origin,
    /// and the length that this connection must have on the horizontal axis.
    ///
    var southConnectionXAndLength: (x: Int, length: Int)? { get set }
    
    /// A pair consisting of the y (vertical) coordinate on which an east connection must have its origin,
    /// and the length that this connection must have on the vertical axis.
    ///
    var eastConnectionYAndLength: (y: Int, length: Int)? { get set }
    
    /// A pair consisting of the y (vertical) coordinate on which a west connection must have its origin,
    /// and the length that this connection must have on the vertical axis.
    ///
    var westConnectionYAndLength: (y: Int, length: Int)? { get set }
    
    /// Creates a new room using the current property values.
    ///
    /// - Returns: A new `Room` instance.
    ///
    func makeRoom() -> Room
}
