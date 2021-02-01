//
//  LevelTexturePreload.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `TexturePreload` subclass representing the preload required for a given `Level`.
///
class LevelTexturePreload: TexturePreload {
    
    /// The level ID of the texture preload.
    ///
    let levelID: LevelID
    
    /// Creates a new instance from the given level ID.
    ///
    /// - Parameter levelID: The `LevelID` of the level that will be played next.
    ///
    init(levelID: LevelID) {
        self.levelID = levelID
        var textureNames = Set<String>()
        if let textureUser = levelID.metatype as? TextureUser.Type {
            textureNames.formUnion(textureUser.textureNames)
        }
        super.init(textureNames: textureNames)
    }
}
