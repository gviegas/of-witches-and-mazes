//
//  LaunchTexturePreload.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `TexturePreload` subclass representing the preload required for the game launch.
///
class GameLaunchTexturePreload: TexturePreload {
    
    /// Creates a new instance.
    ///
    init() {
        var textureNames = Set<String>()
        textureNames.formUnion(MainMenu.textureNames)
        textureNames.formUnion(NewGameMenu.textureNames)
        textureNames.formUnion(LoadGameMenu.textureNames)
        textureNames.formUnion(SettingsMenu.textureNames)
        textureNames.formUnion(UIBackground.textureNames)
        super.init(textureNames: textureNames)
    }
}
