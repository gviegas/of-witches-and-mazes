//
//  Overlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that all overlays must conform to.
///
/// Overlays are dynamic UI elements that appear in front of content being draw, e.g.
/// a notification or a protagonist's status bar. Unlike `Menu`s, overlays can run
/// alongside each other, and they do not need to be opened/started nor closed/finished.
/// The main purpose of overlays is to enchance scenes with dynamic UI content that can
/// be easily added and removed.
///
/// As with `Menu`s, the `node` property must hold all drawable content, must not point to
/// a different instance during its lifetime and must be ready for use after initialization.
///
protocol Overlay: AnyObject {
    
    /// The node where all the overlay drawable content will be appended.
    ///
    var node: SKNode { get }
    
    /// Updates the overlay.
    ///
    /// - Parameter seconds: The elapsed time since the last update.
    ///
    func update(deltaTime seconds: TimeInterval)
}

/// A protocol that defines an `Overlay` that responds to input.
///
protocol ControllableOverlay: Overlay, Controllable {
    
    /// The callback to be called when the overlay does not wish to
    /// respond to input anymore.
    ///
    var onEnd: () -> Void { get set }
}
