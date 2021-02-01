//
//  Launcher.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/11/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The struct responsible for launching the game.
///
struct Launcher {
    
    /// An enum defining the possible states of the launcher.
    ///
    private enum State {
        case notLaunched, launching, launched
    }
    
    /// The current state of the launcher.
    ///
    private static var state = State.notLaunched
    
    /// The flag stating whether or not `Launcher.launch(window:view:completionHandler)` can be called.
    ///
    static var canLaunch: Bool {
        return state == .notLaunched
    }
    
    /// The flag stating whether or not `Launcher.launch(window:view:completionHandler)` has completed.
    ///
    static var launchCompleted: Bool {
        return state == .launched
    }
    
    private init() {}
    
    /// Launches the game asynchronously.
    ///
    /// - Parameters:
    ///   - window: The window object to use for the game.
    ///   - view: The view object to use for the game.
    ///   - completionHandler: A closure to be called when the launch process completes.
    ///
    static func launch(window: NSWindow, view: SKView, completionHandler: @escaping () -> Void) {
        guard state == .notLaunched else {
            fatalError("Launcher.launch(window:view:completionHandler) called while in an invalid state")
        }
        state = .launching
        
        Window.window = window
        SceneManager.view = view
        SceneManager.setScene(LoadingScene(), sceneKind: .loading)
        let flag = SceneManager.switchToScene(ofKind: .loading); assert(flag)
        
        DataFileManager.instance.prepare {
            DataFileManager.instance.downloadConfigurationData { _ in
                TexturePreloadManager.preloadInitialGameTextures {
                    SceneManager.setScene(MenuScene(menuType: MainMenu.self), sceneKind: .mainMenu)
                    SceneManager.setScene(MenuScene(menuType: NewGameMenu.self), sceneKind: .newGameMenu)
                    SceneManager.setScene(MenuScene(menuType: LoadGameMenu.self), sceneKind: .loadGameMenu)
                    SceneManager.setScene(MenuScene(menuType: SettingsMenu.self), sceneKind: .settingsMenu)
                    DispatchQueue.main.async {
                        let flag = SceneManager.switchToScene(ofKind: .mainMenu); assert(flag)
                        state = .launched
                        completionHandler()
                    }
                }
            }
        }
        
        #if DEBUG
        INITDEBUG.run()
        #endif
    }
}
