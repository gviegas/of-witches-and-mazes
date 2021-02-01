//
//  MenuScene.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/20/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Scene` subclass for `Menu` types.
///
class MenuScene: Scene {
    
    /// The last update time.
    ///
    private var lastUpdateTime: TimeInterval
    
    /// The menu instance.
    ///
    private var gameMenu: Menu!
    
    /// The overlays.
    ///
    private var overlays: [ObjectIdentifier: Overlay]
    
    /// The overlay queue of the menu.
    ///
    private let overlayQueue: OverlayQueue
    
    /// The `Menu` instance.
    ///
    var menuInstance: Menu {
        return gameMenu
    }
    
    /// The tooltip overlay.
    ///
    var tooltipOverlay: TooltipOverlay? {
        willSet {
            if let tooltipOverlay = tooltipOverlay {
                tooltipOverlay.node.removeFromParent()
                overlays[ObjectIdentifier(tooltipOverlay)] = nil
            }
            if let newValue = newValue {
//                newValue.node.position = CGPoint(x: -frame.width / 2.0, y: -frame.height / 2.0)
                addChild(newValue.node)
                overlays[ObjectIdentifier(newValue)] = newValue
            }
        }
    }
    
    /// Creates a new instance from the given menu type.
    ///
    /// - Parameter menuType: The type of the `Menu` to create the scene for.
    ///
    init(menuType: Menu.Type) {
        lastUpdateTime = 0
        overlays = [:]
        overlayQueue = OverlayQueue()
        super.init()
        self.gameMenu = menuType.init(rect: frame)
        addChild(gameMenu.node)
        addChild(overlayQueue.node)
        backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        lastUpdateTime = 0
        let _ = gameMenu.open {}
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        gameMenu.close()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        
        // Update the menu
        gameMenu.update(deltaTime: dt)
        // Update the overlays
        for (_, overlay) in overlays { overlay.update(deltaTime: dt) }
        // Update the overlay queue
        overlayQueue.update(deltaTime: dt)
        
        lastUpdateTime = currentTime
    }
    
    override func mouseDown(with event: NSEvent) {
        if let event = createEvent(ofType: .mouseDown, fromNSEvent: event) {
            gameMenu.didReceiveEvent(event)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if let event = createEvent(ofType: .mouseUp, fromNSEvent: event) {
            gameMenu.didReceiveEvent(event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        if let event = createEvent(ofType: .mouseDown, fromNSEvent: event) {
            gameMenu.didReceiveEvent(event)
        }
    }
    
    override func rightMouseUp(with event: NSEvent) {
        if let event = createEvent(ofType: .mouseUp, fromNSEvent: event) {
            gameMenu.didReceiveEvent(event)
        }
    }
    
    override func mouseEnteredTrackingArea(event: MouseEvent) {
        gameMenu.didReceiveEvent(event)
    }
    
    override func mouseExitedTrackingArea(event: MouseEvent) {
        gameMenu.didReceiveEvent(event)
    }
    
    override func keyDown(with event: NSEvent) {
        if let event = createEvent(ofType: .keyDown, fromNSEvent: event) {
            gameMenu.didReceiveEvent(event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let event = createEvent(ofType: .keyUp, fromNSEvent: event) {
            gameMenu.didReceiveEvent(event)
        }
    }
    
    /// Adds a new `Overlay` instance to the scene.
    ///
    /// - Parameter overlay: The overlay to add.
    ///
    func addOverlay(_ overlay: Overlay) {
        let key = ObjectIdentifier(overlay)
        if let _ = overlays[key] { return }
        addChild(overlay.node)
        overlays[key] = overlay
    }
    
    /// Removes an `Overlay` instance from the scene.
    ///
    /// - Parameter overlay: The overlay to remove.
    ///
    func removeOverlay(_ overlay: Overlay) {
        let key = ObjectIdentifier(overlay)
        if let _ = overlays[key] {
            overlay.node.removeFromParent()
            (overlays[key] as? Observer)?.removeFromAllObservables()
            overlays[key] = nil
        }
    }
    
    /// Presents a new, temporary, `NoteOverlay` instance using the scene's `OverlayQueue`.
    ///
    /// - Parameter note: The note to present.
    ///
    func presentNote(_ note: NoteOverlay) {
        overlayQueue.presentNote(note)
    }
    
    /// Enqueues a new, temporary, `PickUpOverlay` instance to the scene's `OverlayQueue`.
    ///
    /// - Parameter notification: The notification overlay to enqueue.
    ///
    func enqueuePickUp(_ pickUp: PickUpOverlay) {
        overlayQueue.enqueuePickUp(pickUp)
    }
    
    override func willDeallocate() {
        overlays.forEach { ($0.value as? Observer)?.removeFromAllObservables() }
    }
}
