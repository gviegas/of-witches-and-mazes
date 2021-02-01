//
//  Window.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/9/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import AppKit

/// A class responsible for applying changes and responding to events on the game window.
///
class Window {
    
    /// A class defining the delegate associated with the window.
    ///
    private class Delegate: NSObject, NSWindowDelegate {
        
        /// The instance of the class.
        ///
        static let instance = Delegate()
        
        private override init() {
            super.init()
        }
        
        func windowDidBecomeMain(_ notification: Notification) {
            guard Window.fullscreenMode else { return }
            NSApp.presentationOptions = [.hideMenuBar, .hideDock]
        }
        
        func windowDidResignMain(_ notification: Notification) {
            NSApp.presentationOptions = []
        }
        
        func windowDidResignKey(_ notification: Notification) {
            MouseInputManager.reset()
            KeyboardInputManager.reset()
            if SceneManager.currentScene is LevelScene {
                let _ = SceneManager.switchToScene(ofKind: .pauseMenu)
            }
        }
        
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            defer { NSApp.terminate(self) }
            return true
        }
        
        func windowWillMiniaturize(_ notification: Notification) {
            MouseInputManager.reset()
            KeyboardInputManager.reset()
            if SceneManager.currentScene is LevelScene {
                let _ = SceneManager.switchToScene(ofKind: .pauseMenu)
            }
        }
        
        func windowWillEnterFullScreen(_ notification: Notification) {
            Window.fullscreenMode = true
            NSApp.presentationOptions = [.hideMenuBar, .hideDock]
        }
        
        func windowWillExitFullScreen(_ notification: Notification) {
            Window.fullscreenMode = false
            NSApp.presentationOptions = []
        }
    }
    
    /// The flag stating whether the window is in fullscreen mode.
    ///
    private static var fullscreenMode = false
    
    /// The flag stating whether the window is in windowed mode.
    ///
    static var windowedMode: Bool {
        return !fullscreenMode
    }
    
    /// The window.
    ///
    /// - Note: The new window must not be in fullscreen mode.
    ///
    static weak var window: NSWindow? {
        didSet {
            oldValue?.delegate = nil
            window?.delegate = Delegate.instance
            fullscreenMode = false
        }
    }
    
    private init() {}
    
    /// Enters fullscreen mode.
    ///
    class func enterFullscreenMode() {
        guard windowedMode, let window = window else { return }
        window.toggleFullScreen(nil)
    }
    
    /// Exits fullscreen mode.
    ///
    class func exitFullscreenMode() {
        guard fullscreenMode, let window = window else { return }
        window.toggleFullScreen(nil)
    }
}
