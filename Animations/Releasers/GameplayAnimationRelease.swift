//
//  GameplayAnimationRelease.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `AnimationRelease` subclass representing the the release of animations used in the gameplay.
///
class GameplayAnimationRelease: AnimationRelease {
    
    /// The protagonist type of the animation release.
    ///
    let protagonistType: Protagonist.Type
    
    /// Creates a new instance from the given protagonist type.
    ///
    /// - Parameter protagonistType: The protagonist type that will be used in the gameplay.
    ///
    init(protagonistType: Protagonist.Type) {
        self.protagonistType = protagonistType
        
        var animationKeys = Set<String>()
        animationKeys.formUnion(ColorAnimation.animationKeys)
        animationKeys.formUnion(LootNode.animationKeys)
        if !(protagonistType is IntroProtagonist.Type) {
            // The following animation keys are used only in the main game
            animationKeys.formUnion(UniversalLootTable.animationKeys)
            animationKeys.formUnion(TradingLootTable.animationKeys)
        }
        if let animationUser = protagonistType as? AnimationUser.Type {
            animationKeys.formUnion(animationUser.animationKeys)
        }
        
        super.init(animationKeys: animationKeys)
    }
}
