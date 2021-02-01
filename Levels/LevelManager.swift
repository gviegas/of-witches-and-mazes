//
//  LevelManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that manages a set of `Level`s available for a game.
///
class LevelManager {
    
    /// The levels, in reverse order.
    ///
    private static var levels: [Level] = []
    
    /// A flag indicating whether or not the levels have started playing.
    ///
    private static var hasStarted = false
    
    /// The current level.
    ///
    static var currentLevel: Level? {
        guard hasStarted else { return nil }
        return levels.last
    }
    
    private init() {
        
    }
    
    /// Sets the list of levels to be managed.
    ///
    /// - Parameter levels: A list of levels to set.
    ///
    class func setLevels(levels: [Level]) {
        self.levels = levels.reversed()
        hasStarted = false
    }
    
    /// Starts the management of the current set of levels, making the first
    /// `Level` instance available.
    ///
    class func start() {
        hasStarted = true
    }
    
    /// Discards the current level and sets the next one.
    ///
    /// Every time this method is called, the `currentLevel` property is set
    /// to return the next level in the sequence, until there are no more levels.
    ///
    /// - Returns: The new level, or `nil` if there are no more levels.
    ///
    @discardableResult
    class func nextLevel() -> Level? {
        guard hasStarted else { return nil }
        let _ = levels.popLast()
        return levels.last
    }
}
