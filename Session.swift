//
//  Session.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import GameplayKit

/// A class that manages the current game session.
///
class Session {
    
    /// An enum that identifies the kind of a `Session`.
    ///
    private enum Kind {
        case game, intro
    }
    
    /// The `Session.Kind` of the current running session.
    ///
    /// If this property is `nil`, no session is running currently.
    ///
    private static var kind: Kind?
    
    /// The `RawData` object in use.
    ///
    private static var currentData: RawData?
    
    /// The flag stating whether or not a session is running.
    ///
    /// - Note: A new session can only start after the current one ends (i.e., after `end(andSave:)` is called).
    ///
    static var isRunning: Bool {
        return kind != nil
    }
    
    private init() {}
    
    /// Starts the game session after the protagonist and raw data are configured.
    ///
    /// - Parameter stageInfo: The stage information from which to create the levels.
    ///
    private class func start(stageInfo: StageInfo) {
        let _ = SceneManager.switchToScene(ofKind: .loading)
        
        if kind == .game, let fileName = currentData?.fileName {
            if ConfigurationData.instance.configurations.lastSaveFileLoaded != fileName {
                ConfigurationData.instance.configurations.lastSaveFileLoaded = fileName
                let _ = ConfigurationData.instance.write()
            }
        }
        
        let protagonistType = type(of: Game.protagonist!) as! Protagonist.Type
        let levelID = stageInfo.currentLevel
        
        AnimationReleaseManager.retainGameAnimations(protagonistType: protagonistType, levelID: levelID)
        
        TexturePreloadManager.preloadGameTextures(protagonistType: protagonistType, levelID: levelID) {
            DispatchQueue.main.async {
                SceneManager.setScene(LevelScene(), sceneKind: .level)
                LevelManager.setLevels(levels: LevelPreparer.fromStageInfo(stageInfo))
                LevelManager.start()
                
                if let bgmSequence = (LevelManager.currentLevel as? BGMSequenceSource)?.bgmSequence {
                    BGMPlayback.setSequence(bgmSequence) ? BGMPlayback.play() : BGMPlayback.dropSequence()
                }
                
                let _ = SceneManager.switchToScene(ofKind: .level)
            }
        }
    }
    
    /// Starts a session for a new game.
    ///
    /// - Parameter protagonist: The protagonist for the new game.
    /// - Returns: `true` if a session could be started, `false` otherwise.
    ///
    class func startAsNewGame(protagonist: Protagonist) -> Bool {
        guard !isRunning else { return false }
        guard protagonist.component(ofType: PersonaComponent.self)?.personaName != "" else { return false }
        
        let stageInfo = StageInfo(run: 1, completion: [], currentLevel: .nightGlade, currentSublevel: 1)
        protagonist.component(ofType: StageComponent.self)?.stageInfo = stageInfo
        
        Game.protagonist = protagonist
        currentData = RawData(creatingNewFileFor: protagonist)
        
        SceneManager.setScene(MenuScene(menuType: PauseMenu.self), sceneKind: .pauseMenu)
        SceneManager.setScene(MenuScene(menuType: CharacterMenu.self), sceneKind: .characterMenu)
        SceneManager.setScene(MenuScene(menuType: TradeMenu.self), sceneKind: .tradeMenu)
        
        kind = .game
        start(stageInfo: stageInfo)
        return true
    }
    
    /// Starts a session for the intro.
    ///
    /// - Parameter protagonist: The protagonist for the intro.
    /// - Returns: `true` if a session could be started, `false` otherwise.
    ///
    class func startAsIntro(protagonist: IntroProtagonist) -> Bool {
        guard !isRunning else { return false }
        
        let stageInfo = StageInfo(run: 1, completion: [], currentLevel: .glade, currentSublevel: 1)
        protagonist.component(ofType: StageComponent.self)?.stageInfo = stageInfo
        
        Game.protagonist = protagonist
        
        SceneManager.setScene(MenuScene(menuType: PauseMenu.self), sceneKind: .pauseMenu)
        SceneManager.setScene(MenuScene(menuType: IntroCharacterMenu.self), sceneKind: .characterMenu)
        
        kind = .intro
        start(stageInfo: stageInfo)
        return true
    }
    
    /// Starts a session from a saved game file.
    ///
    /// - Parameter fileName: The name of the file to load.
    /// - Returns: `true` if a session could be started, `false` otherwise.
    ///
    class func startFromSaveFile(fileName: String) -> Bool {
        guard !isRunning else { return false }
        guard let rawData = RawData(loadingFromFileNamed: fileName) else { return false }
        
        return startFromRawData(rawData: rawData)
    }
    
    /// Starts a session from a `RawData` instance.
    ///
    /// - Parameter rawData: The raw data instance to use.
    /// - Returns: `true` if a session could be started, `false` otherwise.
    ///
    class func startFromRawData(rawData: RawData) -> Bool {
        guard !isRunning else { return false }
        
        let protagonist: Protagonist
        switch rawData.characterType {
        case is Fighter.Type:
            protagonist = Fighter(levelOfExperience: rawData.experience.level, personaName: rawData.personaName)
        case is Rogue.Type:
            protagonist = Rogue(levelOfExperience: rawData.experience.level, personaName: rawData.personaName)
        case is Wizard.Type:
            protagonist = Wizard(levelOfExperience: rawData.experience.level, personaName: rawData.personaName)
        case is Cleric.Type:
            protagonist = Cleric(levelOfExperience: rawData.experience.level, personaName: rawData.personaName)
        default:
            return false
        }
        
        protagonist.component(ofType: StageComponent.self)!.stageInfo = rawData.stageInfo
        protagonist.component(ofType: ProgressionComponent.self)!.gainXP(rawData.experience.amount)
        protagonist.component(ofType: InventoryComponent.self)!.replaceWhole(with: rawData.inventory)
        
        let equipmentComponent = protagonist.component(ofType: EquipmentComponent.self)!
        let equippedItems = rawData.equippedItems
        for i in equippedItems.indices {
            guard let itemIdx = equippedItems[i] else {
                let _ = equipmentComponent.unequip(at: i)
                continue
            }
            if let item = protagonist.component(ofType: InventoryComponent.self)!.itemAt(index: itemIdx) {
                let _ = equipmentComponent.equip(item: item, at: i)
            }
        }
        
        let skillComponent = protagonist.component(ofType: SkillComponent.self)!
        let unlockedSkills = rawData.unlockedSkills
        for i in 0..<min(skillComponent.skills.count, unlockedSkills.count) {
            if unlockedSkills[i] {
                skillComponent.skills[i].unlocked = true
                (skillComponent.skills[i] as? PassiveSkill)?.didUnlock(onEntity: protagonist)
            }
        }
        
        Game.protagonist = protagonist
        currentData = rawData
        
        SceneManager.setScene(MenuScene(menuType: PauseMenu.self), sceneKind: .pauseMenu)
        SceneManager.setScene(MenuScene(menuType: CharacterMenu.self), sceneKind: .characterMenu)
        SceneManager.setScene(MenuScene(menuType: TradeMenu.self), sceneKind: .tradeMenu)
        
        kind = .game
        start(stageInfo: rawData.stageInfo)
        return true
    }
    
    /// Restarts the current session.
    ///
    /// - Parameter save: A flag stating whether or not to save the game before restarting the session.
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    class func restart(andSave save: Bool) -> Bool {
        guard kind == .game, let currentData = currentData else { return false }
        
        if save {
            currentData.updateProtagonistData(using: Game.protagonist as! Protagonist)
            currentData.write()
        }
        
        let protagonist: Protagonist
        switch currentData.characterType {
        case is Fighter.Type:
            protagonist = Fighter(levelOfExperience: currentData.experience.level,
                                  personaName: currentData.personaName)
        case is Rogue.Type:
            protagonist = Rogue(levelOfExperience: currentData.experience.level,
                                personaName: currentData.personaName)
        case is Wizard.Type:
            protagonist = Wizard(levelOfExperience: currentData.experience.level,
                                 personaName: currentData.personaName)
        case is Cleric.Type:
            protagonist = Cleric(levelOfExperience: currentData.experience.level,
                                 personaName: currentData.personaName)
        default:
            return false
        }
        
        protagonist.component(ofType: StageComponent.self)!.stageInfo = currentData.stageInfo
        protagonist.component(ofType: ProgressionComponent.self)!.gainXP(currentData.experience.amount)
        protagonist.component(ofType: InventoryComponent.self)!.replaceWhole(with: currentData.inventory)
        
        let equipmentComponent = protagonist.component(ofType: EquipmentComponent.self)!
        let equippedItems = currentData.equippedItems
        for i in equippedItems.indices {
            guard let itemIdx = equippedItems[i] else {
                let _ = equipmentComponent.unequip(at: i)
                continue
            }
            if let item = protagonist.component(ofType: InventoryComponent.self)!.itemAt(index: itemIdx) {
                let _ = equipmentComponent.equip(item: item, at: i)
            }
        }
        
        let skillComponent = protagonist.component(ofType: SkillComponent.self)!
        let unlockedSkills = currentData.unlockedSkills
        for i in 0..<min(skillComponent.skills.count, unlockedSkills.count) {
            if unlockedSkills[i] {
                skillComponent.skills[i].unlocked = true
                (skillComponent.skills[i] as? PassiveSkill)?.didUnlock(onEntity: protagonist)
            }
        }
        
        Game.protagonist = protagonist
        SceneManager.setScene(LevelScene(), sceneKind: .level)
        LevelManager.setLevels(levels: LevelPreparer.fromStageInfo(currentData.stageInfo))
        LevelManager.start()
        return SceneManager.switchToScene(ofKind: .level)
    }
    
    /// Ends the current session.
    ///
    /// - Parameter save: A flag stating whether or not to save the game before ending the session.
    /// - Returns: `true` if successful, `false` otherwise.
    ///
    class func end(andSave save: Bool) -> Bool {
        guard isRunning else { return false }
        
        if save, kind == .game, let currentData = currentData {
            currentData.updateProtagonistData(using: Game.protagonist as! Protagonist)
            currentData.write()
        }
        
        LevelManager.currentLevel?.finishSublevel()
        LevelManager.setLevels(levels: [])
        SceneManager.setScene(nil, sceneKind: .level)
        SceneManager.setScene(nil, sceneKind: .pauseMenu)
        SceneManager.setScene(nil, sceneKind: .characterMenu)
        SceneManager.setScene(nil, sceneKind: .tradeMenu)
        Game.protagonist!.willRemoveFromGame()
        Game.protagonist = nil
        currentData = nil
        kind = nil
        BGMPlayback.dropSequence()
        AnimationReleaseManager.releaseGameAnimations()
        TexturePreloadManager.unloadGameTextures()
        MouseInputManager.reset()
        KeyboardInputManager.reset()
        return true
    }
    
    /// Saves the current session's data to file.
    ///
    /// - Returns: `true` if the data could be saved, `false` otherwise.
    ///
    class func save() -> Bool {
        guard kind == .game, let currentData = currentData else { return false }
        
        currentData.updateProtagonistData(using: Game.protagonist as! Protagonist)
        currentData.write()
        return true
    }
}
