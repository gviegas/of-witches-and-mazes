//
//  MouseInputManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/11/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation
import SpriteKit

/// A protocol that defines the mouse tracking responder, which enables an object to receive
/// `mouseEntered` and `mouseExited` events from the `MouseInputManager`.
///
protocol MouseTrackingResponder: AnyObject {
    
    /// Informs the responder that the mouse has entered a tracking area.
    ///
    /// - Parameter event: The mouse event holding tracking data.
    ///
    func mouseEnteredTrackingArea(event: MouseEvent)
    
    /// Informs the responder that the mouse has exited a tracking area.
    ///
    /// - Parameter event: The mouse event holding tracking data.
    ///
    func mouseExitedTrackingArea(event: MouseEvent)
}

/// A class that defines the mouse input manager, used to manage the global input state
/// for mice.
///
class MouseInputManager {
    
    /// The current pressed buttons of the mouse.
    ///
    private static var pressedButtons = MouseButton.none.rawValue
    
    /// The set of currently tracked nodes.
    ///
    private static var trackedNodes = Set<SKNode>()
    
    /// The game cursor.
    ///
    static let cursor = NSCursor(image: NSImage(imageLiteralResourceName: "Cursor_11_8"),
                                 hotSpot: CGPoint(x: 11.0, y: 8.0))
    
    /// The flag to enable or disable mouse tracking.
    ///
    static var trackingEnabled = false
    
    /// The flag stating whether or not only the topmost node should be tracked for a given location.
    ///
    static var ignoreNodesBelow = true
    
    /// The delay between mouse tracking updates.
    ///
    static var trackingDelay: TimeInterval = 1.0 / 60.0 {
        didSet {
            if trackingDelay < 0 {
                trackingDelay = oldValue
            }
        }
    }
    
    /// The current location of the mouse in the scene.
    ///
    /// Setting this property will cause the `MouseInputManager` to compute intersections
    /// with nodes in the new location, dispatching mouse tracking events as needed.
    ///
    static var location = CGPoint.zero {
        didSet {
            if trackingEnabled {
                ignoreNodesBelow ? trackOne() : trackAll()
            }
        }
    }
    
    /// The current assigned responder for mouse tracking.
    ///
    static weak var responder: MouseTrackingResponder?
    
    private init() {}
    
    /// Tracks a single node intersecting the current `location` property.
    ///
    private class func trackOne() {
        guard let scene = SceneManager.currentScene else { return }
        
        // Choose which node to track
        var chosenNode: SKNode?
        let nodes = scene.nodes(at: location)
        for node in nodes {
            guard let _ = node.userData?[TrackingKey.key] else { continue }
            
            if chosenNode == nil || node.zPosition > chosenNode!.zPosition {
                chosenNode = node
            }
        }
        
        // Send mouseExited events
        // If ignoreNodesBelow just became true, this will guarantee that mouseExit events are dispatched
        let nodesToRemove = chosenNode == nil ? trackedNodes : trackedNodes.subtracting([chosenNode!])
        for node in nodesToRemove {
            guard let responder = responder, let data = node.userData?[TrackingKey.key] else { continue }
            
            let event = MouseEvent.mouseExitedEvent(button: .none, location: location, data: data)
            responder.mouseExitedTrackingArea(event: event)
        }
        
        // Send mouseEntered event
        if let chosenNode = chosenNode {
            // Return if the chosen node is already being tracked
            guard !trackedNodes.contains(chosenNode) else { return }
            
            trackedNodes = [chosenNode]
            
            guard let responder = responder, let data = chosenNode.userData?[TrackingKey.key] else { return }
            
            let event = MouseEvent.mouseEnteredEvent(button: .none, location: location, data: data)
            responder.mouseEnteredTrackingArea(event: event)
        } else {
            trackedNodes = []
        }
    }
    
    /// Tracks all nodes intersecting the current `location` property.
    ///
    private class func trackAll() {
        guard let scene = SceneManager.currentScene else { return }
        
        // Search for new nodes to track
        var nodesToTrack = Set<SKNode>()
        let nodes = scene.nodes(at: location)
        for node in nodes {
            if let _ = node.userData?[TrackingKey.key] {
                nodesToTrack.insert(node)
            }
        }
        
        // Send mouseExited events
        let nodesToRemove = trackedNodes.subtracting(nodesToTrack)
        for node in nodesToRemove {
            guard let responder = responder, let data = node.userData?[TrackingKey.key] else { continue }
            
            let event = MouseEvent.mouseExitedEvent(button: .none, location: location, data: data)
            responder.mouseExitedTrackingArea(event: event)
        }
        
        // Send mouseEntered events
        nodesToTrack = nodesToTrack.subtracting(trackedNodes)
        for node in nodesToTrack {
            guard let responder = responder, let data = node.userData?[TrackingKey.key] else { continue }
            
            let event = MouseEvent.mouseEnteredEvent(button: .none, location: location, data: data)
            responder.mouseEnteredTrackingArea(event: event)
        }
        
        // Update the trackedNodes property
        trackedNodes = trackedNodes.subtracting(nodesToRemove).union(nodesToTrack)
    }
    
    /// Retrieves all the mouse buttons being pressed.
    ///
    /// - Returns: An array containing all the `MouseButton`s currently set as pressed.
    ///
    class func allPressedMouseButtons() -> [MouseButton] {
        var buttons = [MouseButton]()
        for i in 0...31 {
            guard let button = MouseButton(rawValue: UInt(1) << i) else { continue }
            if (pressedButtons | button.rawValue) == pressedButtons {
                buttons.append(button)
            }
        }
        return buttons
    }
    
    /// Checks if a given mouse button is being pressed.
    ///
    /// - Parameter mouseButton: The mouse button to check.
    /// - Returns: `true` is the mouse button is set as pressed, `false` otherwise.
    ///
    class func isPressed(mouseButton: MouseButton) -> Bool {
        return (pressedButtons | mouseButton.rawValue) == pressedButtons
    }
    
    /// Sets the given mouse button as pressed.
    ///
    /// - Parameter mouseButton: The mouse button to set.
    ///
    class func setPressed(mouseButton: MouseButton) {
        pressedButtons |= mouseButton.rawValue
    }
    
    /// Sets the given mouse button as released.
    ///
    /// - Parameter mouseButton: The mouse button to set.
    ///
    class func setReleased(mouseButton: MouseButton) {
        pressedButtons &= ~mouseButton.rawValue
    }
    
    /// Resets the state of the mouse.
    ///
    /// After calling this method, all pressed mouse buttons will be released,
    /// all tracked nodes will be untracked, the location of the mouse will be set
    /// to `(0, 0)` and the cursor node will be removed from its current hierarchy.
    ///
    class func reset() {
        pressedButtons = MouseButton.none.rawValue
        trackedNodes = []
        location = CGPoint.zero
    }
}
