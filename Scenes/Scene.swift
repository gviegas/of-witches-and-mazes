//
//  Scene.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The base class for all scenes of the game.
///
class Scene: SKScene, SKPhysicsContactDelegate, MouseTrackingResponder {
    
    /// The last update time.
    ///
    private var lastUpdateTime: TimeInterval = 0
    
    /// The elapsed time since the last mouse location update.
    ///
    private var timeSinceLastMouseUpdate: TimeInterval = 0

    override init() {
        let size = Window.window?.screen?.frame.size ?? NSScreen.screens[0].frame.size
        super.init(size: size)
        scaleMode = .aspectFit
        physicsWorld.gravity = CGVector.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates the `MouseInputManager`'s `location` to reflect the current location of
    /// the mouse in the scene.
    ///
    private func updateMouseLocation() {
        let locationInWindow = view!.window!.mouseLocationOutsideOfEventStream
        let locationInView = locationInWindow
        let locationInScene = convertPoint(fromView: locationInView)
        MouseInputManager.location = locationInScene
        timeSinceLastMouseUpdate = 0
    }
    
    override func didMove(to view: SKView) {
        // Set the contact delegate
        physicsWorld.contactDelegate = self
        
        // Reset the state of the mouse input manager
        MouseInputManager.reset()
        // Enable mouse tracking
        MouseInputManager.trackingEnabled = true
        // Set the mouse tracking responder
        MouseInputManager.responder = self
        // Set the location of the cursor
        if let locationInWindow = view.window?.mouseLocationOutsideOfEventStream {
            MouseInputManager.location = convert(locationInWindow, to: self)
        }
        
        // By default, the state of the keyboard input manager will be kept
    }

    final func didBegin(_ contact: SKPhysicsContact) {
        // Call the ContactNotifier's notifyBeginning(nodeNamed:contact:) method to dispatch contact notifications.
        if let name = contact.bodyA.node?.name, Interaction.hasInterest(contact.bodyA, in: contact.bodyB) {
            let con = Contact(body: contact.bodyA, otherBody: contact.bodyB, contactPoint: contact.contactPoint)
            ContactNotifier.notifyBeginning(nodeNamed: name, contact: con)
        }
        if let name = contact.bodyB.node?.name, Interaction.hasInterest(contact.bodyB, in: contact.bodyA) {
            let con = Contact(body: contact.bodyB, otherBody: contact.bodyA, contactPoint: contact.contactPoint)
            ContactNotifier.notifyBeginning(nodeNamed: name, contact: con)
        }
    }
    
    final func didEnd(_ contact: SKPhysicsContact) {
        // Call the ContactNotifier's notifyEnding(nodeNamed:contact:) method to dispatch contact notifications.
        if let name = contact.bodyA.node?.name, Interaction.hasInterest(contact.bodyA, in: contact.bodyB) {
            let con = Contact(body: contact.bodyA, otherBody: contact.bodyB, contactPoint: contact.contactPoint)
            ContactNotifier.notifyEnding(nodeNamed: name, contact: con)
        }
        if let name = contact.bodyB.node?.name, Interaction.hasInterest(contact.bodyB, in: contact.bodyA) {
            let con = Contact(body: contact.bodyB, otherBody: contact.bodyA, contactPoint: contact.contactPoint)
            ContactNotifier.notifyEnding(nodeNamed: name, contact: con)
        }
    }
    
    /// Creates a new `Event` from a `NSEvent`.
    ///
    /// - Parameters:
    ///   - type: The type of the event to create.
    ///   - nsEvent: The `NSEvent` from which to create the event.
    /// - Returns: The `Event` created, or `nil` if could not create an event.
    ///
    final func createEvent(ofType type: EventType, fromNSEvent nsEvent: NSEvent) -> Event? {
        let event: Event?
        
        switch type {
        case .mouseDown:
            let mouseButton: MouseButton
            switch nsEvent.type {
            case .leftMouseDown:
                mouseButton = .left
            case .rightMouseDown:
                mouseButton = .right
            default:
                mouseButton = .none
            }
            
            if MouseInputManager.isPressed(mouseButton: mouseButton) {
                event = nil
            } else {
                event = MouseEvent.mouseDownEvent(button: mouseButton, location: nsEvent.location(in: self))
            }
            
        case .mouseUp:
            let mouseButton: MouseButton
            switch nsEvent.type {
            case .leftMouseUp:
                mouseButton = .left
            case .rightMouseUp:
                mouseButton = .right
            default:
                mouseButton = .none
            }
            
            if MouseInputManager.isPressed(mouseButton: mouseButton) {
                event = MouseEvent.mouseUpEvent(button: mouseButton, location: nsEvent.location(in: self))
            } else {
                event = nil
            }
            
        case .mouseDragged:
            let mouseButton: MouseButton
            if MouseInputManager.isPressed(mouseButton: .left) {
                mouseButton = .left
            } else if MouseInputManager.isPressed(mouseButton: .right) {
                mouseButton = .right
            } else {
                mouseButton = .none
            }
            
            event = MouseEvent.mouseDraggedEvent(button: mouseButton, location: nsEvent.location(in: self))
            
        case .mouseEntered, .mouseExited:
            // The MouseInputManager itself will create and dispatch this events
            event = nil
            
        case .keyDown:
            let characters = nsEvent.characters ?? ""
            let keyCode = UInt(nsEvent.keyCode)
            
            var modifiers: UInt = 0
            if (nsEvent.modifierFlags.rawValue & NSEvent.ModifierFlags.shift.rawValue) != 0 {
                modifiers |= KeyboardModifierKey.shift.rawValue
            }
            if (nsEvent.modifierFlags.rawValue & NSEvent.ModifierFlags.control.rawValue) != 0 {
                modifiers |= KeyboardModifierKey.control.rawValue
            }
            
            let isRepeating: Bool
            if KeyboardInputManager.isPressed(keyCode: keyCode) {
                isRepeating = true
            } else {
                KeyboardInputManager.setPressed(keyCode: keyCode, modifiers: modifiers)
                isRepeating = false
            }
            
            event = KeyboardEvent.keyDownEvent(characters: characters, keyCode: keyCode,
                                               modifiers: modifiers, isRepeating: isRepeating)
            
        case .keyUp:
            let characters = nsEvent.characters ?? ""
            let keyCode = UInt(nsEvent.keyCode)
            KeyboardInputManager.setReleased(keyCode: keyCode)
            event = KeyboardEvent.keyUpEvent(characters: characters, keyCode: keyCode)
        }
        
        return event
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        timeSinceLastMouseUpdate += dt
        
        if timeSinceLastMouseUpdate >= MouseInputManager.trackingDelay {
            updateMouseLocation()
        }
        
        lastUpdateTime = currentTime
    }
    
    func mouseEnteredTrackingArea(event: MouseEvent) {
        
    }
    
    func mouseExitedTrackingArea(event: MouseEvent) {
        
    }
    
    /// Informs the scene that it is about to be deallocated.
    ///
    /// Subclasses should override this method to execute any deinitialization procedures that must
    /// run in the main thread.
    ///
    func willDeallocate() {
        
    }
}
