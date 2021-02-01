//
//  TexturePreloadManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/29/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class responsible for the management of the game's texture preloading.
///
class TexturePreloadManager {
    
    /// The current game launch preload.
    ///
    private static var gameLaunchPreload: GameLaunchTexturePreload?
    
    /// The current gameplay preload.
    ///
    private static var gameplayPreload: GameplayTexturePreload?
    
    /// The current level preload.
    ///
    private static var levelPreload: LevelTexturePreload?
    
    private init() {}
    
    /// Preloads the essential textures required to initialize the game.
    ///
    /// - Parameter onCompletion: A closure to call after all of the textures are loaded.
    ///
    class func preloadInitialGameTextures(onCompletion: @escaping () -> Void) {
        guard gameLaunchPreload == nil else { return }
        
        gameLaunchPreload = GameLaunchTexturePreload()
        gameLaunchPreload!.preloadTextures(onCompletion: onCompletion)
    }
    
    /// Preloads game-related textures.
    ///
    /// - Parameters:
    ///   - protagonistType: The protagonist type that will be used in the game session.
    ///   - levelID: The level ID of the next level that will be played.
    ///   - onCompletion: A closure to call after all of the textures are loaded.
    ///
    class func preloadGameTextures(protagonistType: Protagonist.Type, levelID: LevelID,
                                   onCompletion: @escaping () -> Void) {
        
        let gameplayRequiresPreload = prepareGameplayTextures(protagonistType: protagonistType)
        let levelRequiresPreload = prepareLevelTextures(levelID: levelID)
        
        guard gameplayRequiresPreload || levelRequiresPreload else {
            onCompletion()
            return
        }
        
        var preloadInstances = [TexturePreload]()
        if gameplayRequiresPreload { preloadInstances.append(gameplayPreload!) }
        if levelRequiresPreload { preloadInstances.append(levelPreload!) }
        TexturePreload.preloadMany(preloadInstances, onCompletion: onCompletion)
    }
    
    /// Unloads the initial game textures.
    ///
    /// - Note: This function must not be called while the app is interactive.
    ///
    class func unloadInitialGameTextures() {
        gameLaunchPreload?.unloadTextures()
        gameLaunchPreload = nil
    }
    
    /// Unloads the game textures.
    ///
    /// - Note: This function must not be called while a session is active.
    ///
    class func unloadGameTextures() {
        gameplayPreload?.unloadTextures(ignoringNames: gameLaunchPreload?.textureNames ?? [])
        levelPreload?.unloadTextures(ignoringNames: gameLaunchPreload?.textureNames ?? [])
        gameplayPreload = nil
        levelPreload = nil
    }
    
    /// Prepares the gameplay textures for preload.
    ///
    /// - Parameter protagonistType: The protagonist type that will be used in the game session.
    /// - Returns: `true` if the textures were prepared for preload, `false` if no preload is required.
    ///
    private class func prepareGameplayTextures(protagonistType: Protagonist.Type) -> Bool {
        guard gameplayPreload == nil || gameplayPreload!.protagonistType != protagonistType else { return false }
        
        let newPreload = GameplayTexturePreload(protagonistType: protagonistType)
        gameplayPreload?.unloadTextures(ignoringNames: newPreload.textureNames)
        gameplayPreload = newPreload
        return true
    }
    
    /// Prepares the level textures for preload.
    ///
    /// - Parameter levelID: The level ID of the next level that will be played.
    /// - Returns: `true` if the textures were prepared for preload, `false` if no preload is required.
    ///
    private class func prepareLevelTextures(levelID: LevelID) -> Bool {
        guard levelPreload == nil || levelPreload!.levelID != levelID else { return false }
        
        let newPreload = LevelTexturePreload(levelID: levelID)
        levelPreload?.unloadTextures(ignoringNames: newPreload.textureNames)
        levelPreload = newPreload
        return true
    }
}
