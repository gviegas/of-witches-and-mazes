//
//  SceneManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/11/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The kinds of scene available for the `SceneManager`.
///
enum SceneKind {
    case loading
    case level
    case mainMenu
    case newGameMenu
    case loadGameMenu
    case settingsMenu
    case pauseMenu
    case characterMenu
    case tradeMenu
}

/// A class that manages the scenes of the game.
///
class SceneManager {
    
    /// The scenes.
    ///
    private static var scenes: [SceneKind: Scene] = [:]
    
    /// The private backing for the `currenSceneKind` getter.
    ///
    private static var _currentSceneKind: SceneKind?
    
    /// The current scene kind.
    ///
    static var currentSceneKind: SceneKind? {
        return _currentSceneKind
    }
    
    /// The current scene.
    ///
    static var currentScene: Scene? {
        guard let sceneKind = _currentSceneKind else { return nil }
        return scenes[sceneKind]
    }
    
    /// The `LevelScene` instance stored in the `SceneManager`.
    ///
    static var levelScene: LevelScene? {
        return scenes[.level] as? LevelScene
    }
    
    /// The array containing all `Scene` instances.
    ///
    static var allScenes: [Scene] {
        return [Scene](scenes.values)
    }
    
    /// The view.
    ///
    static weak var view: SKView?
    
    private init() {}
    
    /// Retrieves the scene of the given type stored in the `SceneManager`.
    ///
    /// - Parameter kind: The kind of the scene to retrieve.
    /// - Returns: The `Scene` of the given kind, of `nil` if the `SceneManager` does not have
    ///   this kind of scene.
    ///
    class func scene(ofKind kind: SceneKind) -> Scene? {
        return scenes[kind]
    }
    
    /// Sets the given scenes to be managed, completely replacing the current ones.
    ///
    /// - Note: The replaced scenes must be considered invalid and cannot be used any further.
    ///
    /// - Parameter scenes: A dictionary of `Scene`s to manage, with `SceneKind` as key.
    ///
    class func setScenes(_ scenes: [SceneKind: Scene]) {
        self.scenes.forEach { $0.value.willDeallocate() }
        self.scenes = scenes
    }
    
    /// Sets a given scene to be managed.
    ///
    /// If a scene of the given kind is currently set, it is replaced by the new one.
    ///
    /// - Note: The replaced scene must be considered invalid and cannot be used any further.
    ///
    /// - Parameters:
    ///   - scene: The `Scene` to manage.
    ///   - sceneKind: The `SceneKind` of the new scene.
    ///
    class func setScene(_ scene: Scene?, sceneKind: SceneKind) {
        scenes[sceneKind]?.willDeallocate()
        scenes[sceneKind] = scene
    }
    
    /// Attempts to switch to the scene of the given kind.
    ///
    /// - Parameter sceneKind: The `SceneKind` of the scene to switch to.
    /// - Returns: `true` if could switch to the scene of this kind, `false` otherwise.
    ///
    class func switchToScene(ofKind sceneKind: SceneKind) -> Bool {
        guard let view = view else {
            fatalError("No view is set")
        }
    
        if let scene = scenes[sceneKind] {
            view.presentScene(scene)
            _currentSceneKind = sceneKind
            return true
        }
        return false
    }
}
