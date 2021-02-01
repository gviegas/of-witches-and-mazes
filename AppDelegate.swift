//
//  AppDelegate.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let pause: (Notification) -> Void = { _ in
            MouseInputManager.reset()
            KeyboardInputManager.reset()
            if SceneManager.currentScene is LevelScene {
                let _ = SceneManager.switchToScene(ofKind: .pauseMenu)
            }
        }
        NotificationCenter.default.addObserver(forName: NSMenu.didBeginTrackingNotification,
                                               object: nil, queue: nil, using: pause)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        ConfigurationData.instance.configurations.windowedMode = Window.windowedMode
        let _ = ConfigurationData.instance.write()
        if Session.isRunning {
            let _ = Session.end(andSave: true)
        }
        DataFileManager.instance.terminate()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        BGMPlayback.play()
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        MouseInputManager.reset()
        KeyboardInputManager.reset()
        BGMPlayback.pause()
        if SceneManager.currentScene is LevelScene {
            let _ = SceneManager.switchToScene(ofKind: .pauseMenu)
        }
    }
}
