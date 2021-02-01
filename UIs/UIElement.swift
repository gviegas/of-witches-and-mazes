//
//  UIElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the UI element.
///
/// An element of the UI is any representable thing tha can provide a node to be
/// added to the final interface. `UIElement` instances are held by `UIContainers`,
/// which call the `provideNodeFor(rect:)` method of the element to obtain its node.
/// The `rect` parameter of the aforementioned method defines the exactly bounds of the
/// container - elements must use it to adapt to different UI positions and dimensions.
///
/// - Note: Although `UIContainer`s will correctly position themselves relative to other
///   containers of an `UITree`, they know nothing about the `UIElement`s being added.
///   A container can hold many elements, and they will all receive the same `rect`
///   boundary on `provideNodeFor(rect:)`, so the elements must be aware of their siblings.
///
protocol UIElement {

    /// Provides a node that represents the element, in relation to the given rect.
    ///
    /// This method is intended to be used when building an `UITree`, allowing the
    /// element to set its representable node in accordance to the rect boundaries
    /// of its container.
    ///
    /// - Parameter rect: A rect defining the available area of the `UIContainer` instance
    ///   that contains the element.
    /// - Returns: The node that represents the element.
    ///
    func provideNodeFor(rect: CGRect) -> SKNode
}

extension UIElement {
    
    /// Adds tracking data for the given node.
    ///
    /// - Parameters:
    ///   - node: The node.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForNode(_ node: SKNode, data: Any) -> Bool {
        if let _ = node.userData {
            node.userData!.addEntries(from: [TrackingKey.key: data])
        } else {
            node.userData = NSMutableDictionary(dictionary: [TrackingKey.key: data])
        }
        return true
    }
}
