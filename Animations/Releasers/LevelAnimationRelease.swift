//
//  LevelAnimationRelease.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `AnimationRelease` subclass representing the the release of animations used in a given `Level`.
///
class LevelAnimationRelease: AnimationRelease {
    
    /// The level ID of the animation release.
    ///
    let levelID: LevelID
    
    /// Creates a new instance from the given level ID.
    ///
    /// - Parameter levelID: The `LevelID` of the level that will be played next.
    ///
    init(levelID: LevelID) {
        self.levelID = levelID
        var animationKeys = Set<String>()
        if let animationUser = levelID.metatype as? AnimationUser.Type {
            animationKeys.formUnion(animationUser.animationKeys)
        }
        super.init(animationKeys: animationKeys)
    }
}
