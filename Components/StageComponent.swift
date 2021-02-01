//
//  StageComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A struct that represents information about stage progression.
///
struct StageInfo {
    
    /// The number of the current run through.
    ///
    var run: Int
    
    /// The set that identifies the completed levels for the current run through.
    ///
    var completion: Set<LevelID>
    
    /// The `LevelID` that identifies the current level.
    ///
    var currentLevel: LevelID
    
    /// The number of the current sublevel.
    ///
    var currentSublevel: Int
}

/// A class that provides an entity with information about its progression through the game stages.
///
class StageComponent: Component {
    
    /// The `StageInfo` representing stage information.
    ///
    var stageInfo: StageInfo {
        didSet { broadcast() }
    }
    
    /// Creates a new instance from the given stage information.
    ///
    /// - Parameter stageInfo: A `StageInfo` instance to set on creation.
    ///
    init(stageInfo: StageInfo) {
        self.stageInfo = stageInfo
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
