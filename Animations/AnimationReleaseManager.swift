//
//  AnimationReleaseManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class responsible for the management of the game's animation releasing.
///
class AnimationReleaseManager {
    
    /// The current gameplay release.
    ///
    private static var gameplayRelease: GameplayAnimationRelease?
    
    /// The current level release.
    ///
    private static var levelRelease: LevelAnimationRelease?
    
    private init() {}
    
    /// Retains game-related animations.
    ///
    /// - Parameters:
    ///   - protagonistType: The protagonist type that will be used in the game session.
    ///   - levelID: The level ID of the next level that will be played.
    ///
    class func retainGameAnimations(protagonistType: Protagonist.Type, levelID: LevelID) {
        retainGameplayAnimations(protagonistType: protagonistType)
        retainLevelAnimations(levelID: levelID)
    }
    
    /// Releases the game animations.
    ///
    /// - Note: This function must not be called while a session is active.
    ///
    class func releaseGameAnimations() {
        gameplayRelease?.releaseAnimations()
        levelRelease?.releaseAnimations()
        gameplayRelease = nil
        levelRelease = nil
    }
    
    /// Retains gameplay animations.
    ///
    /// - Parameter protagonistType: The protagonist type that will be used in the game session.
    ///
    private class func retainGameplayAnimations(protagonistType: Protagonist.Type) {
        guard gameplayRelease == nil || gameplayRelease!.protagonistType != protagonistType else { return }
        
        let newRelease = GameplayAnimationRelease(protagonistType: protagonistType)
        gameplayRelease?.releaseAnimations(ignoringKeys: newRelease.animationKeys)
        gameplayRelease = newRelease
    }
    
    /// Retains level animations.
    ///
    /// - Parameter levelID: The level ID of the next level that will be played.
    ///
    private class func retainLevelAnimations(levelID: LevelID) {
        guard levelRelease == nil || levelRelease!.levelID != levelID else { return }
        
        let newRelease = LevelAnimationRelease(levelID: levelID)
        levelRelease?.releaseAnimations(ignoringKeys: newRelease.animationKeys)
        levelRelease = newRelease
    }
}
