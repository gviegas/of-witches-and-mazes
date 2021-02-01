//
//  GameplayTexturePreload.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `TexturePreload` subclass representing the preload required for the gameplay.
///
class GameplayTexturePreload: TexturePreload {
    
    /// The protagonist type of the texture preload.
    ///
    let protagonistType: Protagonist.Type
    
    /// Creates a new instance from the given protagonist type.
    ///
    /// - Parameter protagonistType: The protagonist type that will be used in the gameplay.
    ///
    init(protagonistType: Protagonist.Type) {
        self.protagonistType = protagonistType
        
        var textureNames = Set<String>()
        textureNames.formUnion(PauseMenu.textureNames)
        textureNames.formUnion(CharacterMenu.textureNames)
        textureNames.formUnion(CharacterOverlay.textureNames)
        textureNames.formUnion(TargetOverlay.textureNames)
        textureNames.formUnion(NoteOverlay.textureNames)
        textureNames.formUnion(TooltipOverlay.textureNames)
        textureNames.formUnion(ConfirmationOverlay.textureNames)
        textureNames.formUnion(PromptOverlay.textureNames)
        textureNames.formUnion(PickUpOverlay.textureNames)
        textureNames.formUnion(OptionOverlay.textureNames)
        textureNames.formUnion(LootNode.textureNames)
        textureNames.formUnion(StatusBarComponent.textureNames)
        textureNames.formUnion(ConditionComponent.textureNames)
        textureNames.formUnion(SpeechComponent.textureNames)
        textureNames.formUnion(MazeMinimap.textureNames)
        
        if protagonistType is IntroProtagonist.Type {
            // The following texture names are only used in the intro
            textureNames.formUnion(PageOverlay.textureNames)
        } else {
            // The following texture names are only used in the main game
            textureNames.formUnion(TradeMenu.textureNames)
            textureNames.formUnion(DialogOverlay.textureNames)
            textureNames.formUnion(GameOverOverlay.textureNames)
            textureNames.formUnion(UniversalLootTable.textureNames)
            textureNames.formUnion(TradingLootTable.textureNames)
        }
        
        if let textureUser = protagonistType as? TextureUser.Type {
            textureNames.formUnion(textureUser.textureNames)
        }
        
        super.init(textureNames: textureNames)
    }
}
