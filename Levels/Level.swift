//
//  Level.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/7/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that all playable game stages must conform to.
///
/// Levels create and manage a set of related stages, or sublevels, where the game takes place.
/// First, the `nextSublevel(onEnd:)` method must be called to create a new sublevel. With a
/// a new sublevel created, the `update(deltaTime:)` method must then be called, once per frame,
/// to update the sublevel elements. The `onEnd` callback of `nextSublevel(onEnd:)` signals
/// the end of the sublevel.
///
protocol Level: AnyObject {
    
    /// Creates the next sublevel.
    ///
    /// - Parameter onEnd: A callback to be called when the sublevel ends.
    /// - Returns: A node where all the sublevel drawable content will be appended, or `nil` if there are
    ///   no more sublevels to play or one is already playing.
    ///
    func nextSublevel(onEnd: @escaping () -> Void) -> SKNode?
    
    /// Updates the current sublevel.
    ///
    /// - Parameter seconds: The elapsed time since the last update.
    ///
    func update(deltaTime seconds: TimeInterval)
    
    /// Finds a path, in the current sublevel, from the `origin` to the `goal`.
    ///
    /// - Parameters:
    ///   - origin: The position to start the search from.
    ///   - goal: The position to end the search at.
    /// - Returns: A sequence of points to follow, an empty array if there are no obstacles in the way or
    ///   `nil` if no path could be found. The `origin` and `goal` points are excluded from the resulting array.
    ///
    func findPathFrom(_ origin: CGPoint, to goal: CGPoint) -> [CGPoint]?
    
    /// Adds content to the level.
    ///
    /// This method allows the addition of content during a sublevel execution.
    ///
    func addContent(_ content: Content, at position: CGPoint)
    
    /// Adds a node to run alongside the level contents.
    ///
    /// This method allows the drawing of custom nodes in a sublevel. The nodes added this way will not
    /// be managed by the level, and so they will remain in the scene graph regardless of which rooms are
    /// being processed. Thus, adding long-lived nodes using this method is discouraged.
    ///
    /// - Parameter node: The node to add.
    ///
    func addNode(_ node: SKNode)
 
    /// Removes the given entity from the current sublevel.
    ///
    /// - Parameter entity: The entity to remove.
    ///
    func removeFromSublevel(entity: Entity)
    
    /// Finishes the current sublevel immediately.
    ///
    func finishSublevel()
    
    /// Provides a `Minimap` type representing the current sublevel.
    ///
    /// - Returns: A new `Minimap` object for the current sublevel, or `nil` if no sublevel is playing.
    ///
    func provideMinimap() -> Minimap?
}
