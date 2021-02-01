//
//  MouseEvent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/11/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation
import SpriteKit

/// An enum that defines the mouse buttons.
///
enum MouseButton: UInt {
    case none = 0
    case left = 0x01
    case right = 0x02
}

/// An `Event` type for mouse input.
///
class MouseEvent: Event {
    
    let type: EventType
    
    /// The `MouseButton`.
    ///
    let button: MouseButton
    
    /// The location of the cursor in the scene.
    ///
    let location: CGPoint
    
    /// The optional custom data for the event.
    ///
    let data: Any?
    
    /// Creates anew instance from the given values.
    ///
    /// - Parameters:
    ///   - type: The type of the event.
    ///   - button: The `MouseButton`.
    ///   - location: The location of the cursor in the scene.
    ///   - data: An optional custom data.
    ///
    init(type: EventType, button: MouseButton, location: CGPoint, data: Any?) {
        self.type = type
        self.button = button
        self.location = location
        self.data = data
    }
    
    /// Creates a new `MouseEvent` representing a mouse down event.
    ///
    /// - Parameters:
    ///   - button: The `MouseButton`.
    ///   - location: The location of the cursor in the scene.
    /// - Returns: A new `MouseEvent`.
    ///
    class func mouseDownEvent(button: MouseButton, location: CGPoint) -> MouseEvent {
        return MouseEvent(type: .mouseDown, button: button, location: location, data: nil)
    }
    
    /// Creates a new `MouseEvent` representing a mouse up event.
    ///
    /// - Parameters:
    ///   - button: The `MouseButton`.
    ///   - location: The location of the cursor in the scene.
    /// - Returns: A new `MouseEvent`.
    ///
    class func mouseUpEvent(button: MouseButton, location: CGPoint) -> MouseEvent {
        return MouseEvent(type: .mouseUp, button: button, location: location, data: nil)
    }
    
    /// Creates a new `MouseEvent` representing a mouse dragged event.
    ///
    /// - Parameters:
    ///   - button: The `MouseButton`.
    ///   - location: The location of the cursor in the scene.
    /// - Returns: A new `MouseEvent`.
    ///
    class func mouseDraggedEvent(button: MouseButton, location: CGPoint) -> MouseEvent {
        return MouseEvent(type: .mouseDragged, button: button, location: location, data: nil)
    }
    
    /// Creates a new `MouseEvent` representing a mouse entered event.
    ///
    /// - Parameters:
    ///   - button: The `MouseButton`.
    ///   - location: The location of the cursor in the scene.
    ///   - data: The custom data of the event.
    /// - Returns: A new `MouseEvent`.
    ///
    class func mouseEnteredEvent(button: MouseButton, location: CGPoint, data: Any) -> MouseEvent {
        return MouseEvent(type: .mouseEntered, button: button, location: location, data: data)
    }
    
    /// Creates a new `MouseEvent` representing a mouse exited event.
    ///
    /// - Parameters:
    ///   - button: The `MouseButton`.
    ///   - location: The location of the cursor in the scene.
    ///   - data: The custom data of the event.
    /// - Returns: A new `MouseEvent`.
    ///
    class func mouseExitedEvent(button: MouseButton, location: CGPoint, data: Any) -> MouseEvent {
        return MouseEvent(type: .mouseExited, button: button, location: location, data: data)
    }
}
