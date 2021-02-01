//
//  Event.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum that defines the available types of events.
///
enum EventType {
    case mouseDown, mouseUp, mouseEntered, mouseExited, mouseDragged
    case keyDown, keyUp
}

/// A protocol for input events.
///
protocol Event {
    
    /// The type of the event.
    ///
    var type: EventType { get }
}

extension Event {
    
    /// The flag stating wheter this is a key event.
    ///
    var isKeyEvent: Bool {
        switch type {
        case .keyDown, .keyUp:
            return true
        default:
            return false
        }
    }
    
    /// The flag stating wheter this is a mouse event.
    ///
    var isMouseEvent: Bool {
        return !isKeyEvent
    }
}
