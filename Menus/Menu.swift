//
//  Menu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/18/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that all game menus should conform to.
///
/// Menus should be used to display and update custom, self-contained logic for the game. They will not
/// run alongside `Level` instances - game sublevels are guaranteed to be paused/finished when a given
/// menu is being updated.
/// First, a menu is initialized with a rect that defines its boundaries. A call to `open(onClose:)` is
/// then used to open the menu, and the `update(deltaTime:)` method called, every frame, to update its
/// contents. The `close()` method can be used to close the menu at any time.
///
/// Note that the `node` property will hold all the menu contents, even when the menu is closed. `Menu`
/// implementations must ensure that the `node` property points to the same object during its lifetime.
///
protocol Menu: AnyObject, Controllable {
    
    /// The node where all the menu drawable content will be appended.
    ///
    var node: SKNode { get }
    
    /// Creates a new instance.
    ///
    /// - Parameter rect: A rect defining the boundaries of the menu.
    ///
    init(rect: CGRect)
    
    /// Opens the menu.
    ///
    /// - Parameter onClose: A callback to be called when the menu closes.
    /// - Returns: `true` if successful, `false` if the menu is already open.
    ///
    func open(onClose: @escaping () -> Void) -> Bool
    
    /// Updates the menu.
    ///
    /// - Parameter seconds: The elapsed time since the last update.
    ///
    func update(deltaTime seconds: TimeInterval)
    
    /// Closes the menu.
    ///
    func close()
}

extension Menu {
    
    /// The current `MenuScene`.
    ///
    var menuScene: MenuScene? { return SceneManager.currentScene as? MenuScene }
    
    /// Makes the menu appears less prominently.
    ///
    func dull() {
        node.alpha = 0.1
    }
    
    /// Removes the `dull` effect.
    ///
    func undull() {
        node.alpha = 1.0
    }
}
