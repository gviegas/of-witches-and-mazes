//
//  ViewController.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController {
    
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            view.preferredFramesPerSecond = 60
            view.ignoresSiblingOrder = true
            
            view.addTrackingArea(NSTrackingArea(rect: .zero,
                                                options: [.activeInKeyWindow, .cursorUpdate, .inVisibleRect],
                                                owner: self,
                                                userInfo: nil))
            
            Launcher.launch(window: NSApp.windows.first!, view: view) {
                DispatchQueue.main.async {
                    ConfigurationData.instance.apply()
                }
            }
        }
    }
    
    override func cursorUpdate(with event: NSEvent) {
        MouseInputManager.cursor.set()
    }
}
