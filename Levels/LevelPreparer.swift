//
//  LevelPreparer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that prepares the game's `Level`s in the order that they should be presented by
/// the `LevelManager`.
///
struct LevelPreparer {
    
    /// Prepares the levels using the given `StageInfo`.
    ///
    /// - Parameter stageInfo: A `StageInfo` describing current stage progression.
    /// - Returns: A list of levels to present, intended for `LevelManager` use.
    ///
    static func fromStageInfo(_ stageInfo: StageInfo) -> [Level] {
        guard stageInfo.currentLevel != .glade else {
            // Intro level is a special case
            return [GladeDungeonLevel(isFirst: true), GladeDungeonLevel(isFirst: false)]
        }
        
        // Create the Level instances ordered by LevelID, starting from the stage's currentLevel
        var levels = [Level]()
        var levelID: LevelID! = stageInfo.currentLevel
        repeat {
            if let metatype = levelID.metatype as? SublevelInitializable.Type {
                let sublevel = levelID == stageInfo.currentLevel ? stageInfo.currentSublevel : 1
                if let level = metatype.init(currentSublevel: sublevel) {
                    levels.append(level)
                }
            }
            let value = levelID.rawValue
            levelID = LevelID(rawValue: value + 1)
        } while levelID != nil
        return levels
    }
}
